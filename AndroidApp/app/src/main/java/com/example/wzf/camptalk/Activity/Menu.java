package com.example.wzf.camptalk.Activity;

import android.content.Intent;
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

import org.w3c.dom.Text;

public class Menu extends AppCompatActivity implements View.OnClickListener {
    private List<Fragment> fragmentList;

    private ViewPager pager;  //实例

    private LinearLayout hallList, friendList, space;
    private TextView hallTitle, friendTitle, spaceTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);
        // 隐藏原有的标题栏
        android.support.v7.app.ActionBar actionBar=getSupportActionBar();
        if(actionBar!=null)
        {
            actionBar.hide();
        }
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

    private TextView search;
    private TextView setting;
    private LinearLayout searchLL;
    private LinearLayout settingLL;


    @Override
    public void onClick(View view) {
        // 业务目标：改变颜色、实现页面跳转
        if(view == search) {

        }
        if(view == setting) {

        }
        if(view == searchLL) {
            Intent intent = new Intent(Menu.this, Search.class);
            startActivity(intent);
        }
        if(view == settingLL) {
            Intent intent = new Intent(Menu.this, Settings.class);
            startActivity(intent);
        }
        if(view == hallList) {
            pager.setCurrentItem(1);
        }
        if(view == space) {
            pager.setCurrentItem(2);
        }
    }

    private void initView() {
        search = (TextView) findViewById(R.id.search);
        setting = (TextView) findViewById(R.id.search);
        searchLL = (LinearLayout) findViewById(R.id.searchLL);
        settingLL = (LinearLayout) findViewById(R.id.settingLL);

        pager = (ViewPager) findViewById(R.id.main_pager);
        hallList = (LinearLayout) findViewById(R.id.hall_list);
        hallList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                pager.setCurrentItem(0);
            }
        });

        friendList = (LinearLayout) findViewById(R.id.friend_list);
//        friendList.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//
//            }
//        });

        space = (LinearLayout) findViewById(R.id.space);
//        space.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                pager.setCurrentItem(2);
//            }
//        });

        hallTitle = (TextView) findViewById(R.id.hall_title);
        friendTitle = (TextView) findViewById(R.id.friend_title);
        spaceTitle = (TextView) findViewById(R.id.space_title);

        // 将大厅按钮设为按下去的颜色
        hallTitle.setTextColor(getResources().getColor(R.color.colorPrimary));

        // 为布局设置监听事件
        settingLL.setOnClickListener(this);
        searchLL.setOnClickListener(this);
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
