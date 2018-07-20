package com.example.wzf.camptalk.Activity;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.wzf.camptalk.R;

import java.util.ArrayList;
import java.util.List;

public class Settings extends AppCompatActivity implements View.OnClickListener {

    private ListView optionList;
    private List<Integer> imageIds = new ArrayList<>();
    private List<String> names = new ArrayList<>();
    private List<Option> optionArrayList = new ArrayList<Option>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.settings);
        // 隐藏原有的标题栏
        android.support.v7.app.ActionBar actionBar=getSupportActionBar();
        if(actionBar!=null)
        {
            actionBar.hide();
        }


        bindObject();
        getData();

        OptionAdapter optionAdapter = new OptionAdapter(this,
                R.layout.list_view, optionArrayList);

        optionList = (ListView) findViewById(R.id.optionsList);

        optionList.setAdapter(optionAdapter);

        optionList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position,
                                    long id) {
                Option option = optionArrayList.get(position);         //获取点击的那一行
                Toast.makeText(getApplicationContext(),option.getImageName(),Toast.LENGTH_LONG).show();//使用吐司输出点击那行水果的名字
            }
        });
    }



    private void getData() {
        // 清空原有数据，重新加载新数据
        emptyData();

        imageIds.add(R.drawable.settings_icon);
        imageIds.add(R.drawable.settings_icon);

        names.add("修改个人信息");
        names.add("退出账号");

        for(int i = 0 ; i < imageIds.size() ; i++){                  //将数据添加到集合中
            optionArrayList.add(new Option(imageIds.get(i),names.get(i)));  //将图片id和对应的name存储到一起
        }
    }

    private void emptyData() {
    }

    private LinearLayout backLL;
    private TextView back;

    private void bindObject() {
        TextView back = (TextView) findViewById(R.id.back);
        LinearLayout backLL = (LinearLayout) findViewById(R.id.backLL);
    }


    @Override
    public void onClick(View view) {
        if(view == back) {

        }
        if(view == backLL) {

        }
    }
}
