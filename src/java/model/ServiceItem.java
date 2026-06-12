package com.clinic.model;

public class ServiceItem {
    private int id;
    private String serviceName;
    private double price;
    private int durationMins;
    private boolean requiresFasting;
    private boolean requiresFullBladder;
    private String requiredRoomType;

    public ServiceItem(int id, String serviceName, double price, int durationMins, boolean requiresFasting, boolean requiresFullBladder, String requiredRoomType) {
        this.id = id;
        this.serviceName = serviceName;
        this.price = price;
        this.durationMins = durationMins;
        this.requiresFasting = requiresFasting;
        this.requiresFullBladder = requiresFullBladder;
        this.requiredRoomType = requiredRoomType;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public int getDurationMins() { return durationMins; }
    public void setDurationMins(int durationMins) { this.durationMins = durationMins; }
    public boolean isRequiresFasting() { return requiresFasting; }
    public void setRequiresFasting(boolean requiresFasting) { this.requiresFasting = requiresFasting; }
    public boolean isRequiresFullBladder() { return requiresFullBladder; }
    public void setRequiresFullBladder(boolean requiresFullBladder) { this.requiresFullBladder = requiresFullBladder; }
    public String getRequiredRoomType() {
        return requiredRoomType;
    }
    public void setRequiredRoomType(String requiredRoomType) {
        this.requiredRoomType = requiredRoomType;
    }
}
