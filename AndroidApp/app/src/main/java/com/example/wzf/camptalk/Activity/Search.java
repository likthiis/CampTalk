package com.example.wzf.camptalk.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.design.widget.TabLayout;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;

import com.example.wzf.camptalk.R;

import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;
import butterknife.ButterKnife;

public class Search extends AppCompatActivity implements View.OnClickListener {
    @Bind(R.id.tab)
    TabLayout tabLayout;
    @Bind(R.id.viewpager)
    ViewPager viewpager;
    @Bind(R.id.backLL)
    LinearLayout backLL;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_tab);
        ButterKnife.bind(this);

//        tabLayout.setTabTextColors(Color.WHITE, Color.GRAY);//设置文本在选中和为选中时候的颜色
//        tabLayout.setSelectedTabIndicatorColor(Color.WHITE);//设置选中时的指示器的颜色
//        tabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);//可滑动，默认是FIXED


        List<Fragment> fragments = new ArrayList<>();
        fragments.add(new SearchUser());
        fragments.add(new SearchGroup());

        TitleFragmentPagerAdapter adapter = new TitleFragmentPagerAdapter(getSupportFragmentManager(), fragments, new String[]{"第一栏", "第二栏"});
        viewpager.setAdapter(adapter);

        tabLayout.setupWithViewPager(viewpager);

        // 对布局添加监听
        backLL.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if(view == backLL) {
            // 返回主界面
            Log.i("backLL", "点击触发");
            Intent intent = new Intent(Search.this, Menu.class);
            startActivity(intent);
        }
    }
}
