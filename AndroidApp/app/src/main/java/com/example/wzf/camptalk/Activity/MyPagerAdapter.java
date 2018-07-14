package com.example.wzf.camptalk.Activity;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.view.View;
import java.util.List;

public class MyPagerAdapter extends FragmentPagerAdapter {

    private List<Fragment> list;

    //实现构造方法
    public MyPagerAdapter(FragmentManager fm, List<Fragment> list) {
        super(fm);
        this.list = list;
    }

    /*
    ViewPager正常一次加载三个
    多余的摧毁
     */

    @Override
    public int getCount() {
        return list.size();  //返回当前页卡数量
    }

//    @Override
//    public boolean isViewFromObject(View view, Object object) {   //View是否来自对象
//        return view == object;
//    }


    @Override
    public Fragment getItem(int position) {
        return list.get(position);
    }
}
