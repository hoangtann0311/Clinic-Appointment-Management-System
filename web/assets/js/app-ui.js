/* global bootstrap */
(function () {
    'use strict';

    var RESTORE_KEY = 'cams.restore-scroll';
    var TOAST_DURATION = 5000;

    function escapeText(value) {
        var node = document.createElement('span');
        node.textContent = value || '';
        return node.innerHTML;
    }

    function toastRegion() {
        var region = document.getElementById('cams-toast-region');
        if (!region) {
            region = document.createElement('div');
            region.id = 'cams-toast-region';
            region.setAttribute('aria-live', 'polite');
            region.setAttribute('aria-atomic', 'false');
            document.body.appendChild(region);
        }
        return region;
    }

    function normalizeLevel(level) {
        return ['success', 'danger', 'warning', 'info'].indexOf(level) >= 0 ? level : 'info';
    }

    function iconFor(level) {
        return {
            success: 'bi-check-circle-fill',
            danger: 'bi-exclamation-triangle-fill',
            warning: 'bi-exclamation-circle-fill',
            info: 'bi-info-circle-fill'
        }[level];
    }

    function dismissToast(toast) {
        if (!toast || toast.classList.contains('is-leaving')) return;
        // Cancel any running progress animation
        if (toast._progressRaf) { cancelAnimationFrame(toast._progressRaf); toast._progressRaf = null; }
        toast.classList.add('is-leaving');
        window.setTimeout(function () { toast.remove(); }, 260);
    }

    function startProgress(toast, duration) {
        var bar = toast.querySelector('.cams-toast__progress');
        if (!bar) return;
        var startedAt = performance.now();
        var finished = false;
        function tick(now) {
            if (finished) return;
            var elapsed = now - startedAt;
            var pct = Math.max(0, 100 - (elapsed / duration) * 100);
            bar.style.width = pct.toFixed(1) + '%';
            if (elapsed >= duration) {
                finished = true;
                dismissToast(toast);
            } else {
                toast._progressRaf = requestAnimationFrame(tick);
            }
        }
        toast._progressRaf = requestAnimationFrame(tick);
    }

    function notify(message, level, duration) {
        level = normalizeLevel(level);
        var autoDuration = duration || TOAST_DURATION;
        var toast = document.createElement('div');
        toast.className = 'cams-toast cams-toast--' + level;
        toast.setAttribute('role', level === 'danger' ? 'alert' : 'status');
        // Progress bar inside the toast \u2014 drains over duration
        toast.innerHTML = '<i class="bi ' + iconFor(level) + ' cams-toast__icon" aria-hidden="true"></i>'
            + '<div class="cams-toast__body">' + escapeText(message) + '</div>'
            + '<button type="button" class="cams-toast__close" aria-label="\u0110\u00f3ng th\u00f4ng b\u00e1o"><i class="bi bi-x-lg"></i></button>'
            + '<div class="cams-toast__progress" style="width:100%"></div>';
        var region = toastRegion();
        // Prepend so newest appears on top
        region.insertBefore(toast, region.firstChild);
        toast.querySelector('.cams-toast__close').addEventListener('click', function () { dismissToast(toast); });
        // Pause progress bar on hover
        toast.addEventListener('mouseenter', function () {
            if (toast._progressRaf) { cancelAnimationFrame(toast._progressRaf); toast._progressRaf = null; }
        });
        toast.addEventListener('mouseleave', function () {
            if (!toast.classList.contains('is-leaving')) {
                var bar = toast.querySelector('.cams-toast__progress');
                var remaining = bar ? parseFloat(bar.style.width) : 100;
                startProgress(toast, autoDuration * (remaining / 100));
            }
        });
        startProgress(toast, autoDuration);
        return toast;
    }

    function levelFromAlert(alert) {
        if (alert.classList.contains('alert-success')) return 'success';
        if (alert.classList.contains('alert-danger')) return 'danger';
        if (alert.classList.contains('alert-warning')) return 'warning';
        return 'info';
    }

    function alertText(alert) {
        var clone = alert.cloneNode(true);
        Array.prototype.forEach.call(clone.querySelectorAll('.btn-close, button, [aria-label="Close"], [aria-label="\u0110\u00f3ng"]'), function (button) {
            button.remove();
        });
        return (clone.textContent || '').replace(/\s+/g, ' ').trim();
    }

    function convertFlashAlerts() {
        var alerts = document.querySelectorAll('.alert');
        Array.prototype.forEach.call(alerts, function (alert) {
            if (alert.dataset.camsToastHandled === 'true' || alert.closest('#cams-toast-region')) return;
            // Only transient flash messages may become toasts. Persistent
            // clinical/status panels also use alert-success/alert-danger and
            // must stay in the page instead of reappearing as a new toast on
            // every GET/navigation.
            var isExplicit = alert.hasAttribute('data-cams-toast') || alert.classList.contains('alert-dismissible');
            if (!isExplicit) return;
            var message = alert.dataset.camsToastMessage || alertText(alert);
            if (!message) return;
            alert.dataset.camsToastHandled = 'true';
            notify(message, alert.dataset.camsToastLevel || levelFromAlert(alert));
            alert.remove();
        });
    }

    function saveScrollForPost(form) {
        var method = (form.getAttribute('method') || 'get').toLowerCase();
        if (method !== 'post' || form.dataset.camsScrollReset === 'true') return;
        try {
            sessionStorage.setItem(RESTORE_KEY, JSON.stringify({
                path: window.location.pathname,
                y: window.scrollY || window.pageYOffset || 0,
                at: Date.now()
            }));
        } catch (ignored) { }
    }

    function restoreScrollAfterPost() {
        try {
            var saved = JSON.parse(sessionStorage.getItem(RESTORE_KEY) || 'null');
            if (!saved || saved.path !== window.location.pathname || Date.now() - saved.at > 20000) return;
            sessionStorage.removeItem(RESTORE_KEY);
            window.history.scrollRestoration = 'manual';
            window.requestAnimationFrame(function () {
                window.requestAnimationFrame(function () { window.scrollTo(0, saved.y); });
            });
        } catch (ignored) { }
    }

    function setPendingState(form) {
        if (form.dataset.camsPending === 'true') return;
        form.dataset.camsPending = 'true';
        form.classList.add('cams-form-pending');
        var submitter = document.activeElement && document.activeElement.matches('button[type="submit"], input[type="submit"]')
            ? document.activeElement : form.querySelector('button[type="submit"], input[type="submit"]');
        if (!submitter) return;
        submitter.disabled = true;
        if (submitter.tagName === 'BUTTON') {
            submitter.dataset.camsOriginalHtml = submitter.innerHTML;
            submitter.innerHTML = '<span class="cams-submit-busy" aria-hidden="true"></span>\u0110ang x\u1eed l\u00fd\u2026';
        }
    }

    function preparePostForm(form) {
        if (!form || (form.getAttribute('method') || 'get').toLowerCase() !== 'post') return;
        saveScrollForPost(form);
        if (form.dataset.camsNoBusy !== 'true' && form.checkValidity()) {
            setPendingState(form);
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        restoreScrollAfterPost();
        convertFlashAlerts();

        document.addEventListener('submit', function (event) {
            if (event.defaultPrevented) return;
            var form = event.target;
            if (!form || form.tagName !== 'FORM') return;
            preparePostForm(form);
        });
    });

    window.CAMS = window.CAMS || {};
    window.CAMS.notify = notify;
    window.CAMS.preparePostForm = preparePostForm;
    // Legacy screens still call alert(). Keep their validation flow but render
    // every message consistently as a non-blocking, auto-dismissing top-right toast.
    window.alert = function (message) { notify(String(message || ''), 'warning'); };
}());
