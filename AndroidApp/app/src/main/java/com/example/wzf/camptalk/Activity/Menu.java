package com.example.wzf.camptalk.Activity;

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;
import com.example.wzf.camptalk.R;

public class Menu extends AppCompatActivity {
    private List<Fragment> fragmentList;

    private ViewPager pager;  //实例

    private LinearLayout hallList, friendList, space;
    private TextView hallTitle, friendTitle, spaceTitle;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);
        getWindow().setFeatureInt(Window.FEATURE_CUSTOM_TITLE, R.layout.title);

        initView();


        fragmentList = new ArrayList<>();
        fragmentList.add(new HallList());
        fragmentList.add(new FriendsList());
        fragmentList.add(new Space());

        //创建pagerAdapter适配器
        pager.setAdapter(new MyPagerAdapter(getSupportFragmentManager(), fragmentList));
        pager.setCurrentItem(0);
        pager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                setTextColor(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    private void initView() {
        pager = (ViewPager) findViewById(R.id.main_pager);
        hallList = (LinearLayout) findViewById(R.id.hall_list);
        hallList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pager.setCurrentItem(0);
            }
        });

        friendList = (LinearLayout) findViewById(R.id.friend_list);
        friendList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pager.setCurrentItem(1);
            }
        });

        space = (LinearLayout) findViewById(R.id.space);
        space.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pager.setCurrentItem(2);
            }
        });

        hallTitle = (TextView) findViewById(R.id.hall_title);
        friendTitle = (TextView) findViewById(R.id.friend_title);
        spaceTitle = (TextView) findViewById(R.id.space_title);
    }

    private void setTextColor(int position) {
        hallTitle.setTextColor(getResources().getColor(R.color.colorAccent));
        friendTitle.setTextColor(getResources().getColor(R.color.colorAccent));
        spaceTitle.setTextColor(getResources().getColor(R.color.colorAccent));

        switch (position) {
            case 0:
                hallTitle.setTextColor(getResources().getColor(R.color.colorPrimary));
                break;
            case 1:
                friendTitle.setTextColor(getResources().getColor(R.color.colorPrimary));
                break;
            case 2:
                spaceTitle.setTextColor(getResources().getColor(R.color.colorPrimary));
                break;
        }
    }
}
