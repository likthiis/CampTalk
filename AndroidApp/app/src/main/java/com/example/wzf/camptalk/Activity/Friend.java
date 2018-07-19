package com.example.wzf.camptalk.Activity;

public class Friend {
    private int imageId;
    private String imageName;

    public Friend(int imageId, String imageName) {
        super();
        this.imageId = imageId;
        this.imageName = imageName;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public String getImageName() {
        return imageName;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }
}
