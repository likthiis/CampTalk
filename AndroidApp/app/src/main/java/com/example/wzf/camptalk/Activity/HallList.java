package com.example.wzf.camptalk.Activity;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import android.widget.AdapterView.OnItemClickListener;

import com.example.wzf.camptalk.R;

import java.util.ArrayList;
import java.util.List;

import butterknife.ButterKnife;

public class HallList extends Fragment {

    private ListView hallList;

    private List<Hall> hallArrayList = new ArrayList<Hall>();

    private View view;

    private static final String TAG = HallList.class.getSimpleName();

    View mRootView;

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        view = inflater.inflate(R.layout.hall_list, container, false);
        return view;
    }


    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        hallList = (ListView) view.findViewById(R.id.hallList);

        getData();

        HallAdapter hallAdapter = new HallAdapter(this.getActivity(),
                R.layout.list_view, hallArrayList);

        hallList.setAdapter(hallAdapter);

        hallList.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position,
                                    long id) {
                Hall hall=hallArrayList.get(position);         //获取点击的那一行
                Toast.makeText(HallList.this.getActivity(),hall.getImageName(),Toast.LENGTH_LONG).show();//使用吐司输出点击那行水果的名字
            }
        });

    }

    private List<Integer> imageIds = new ArrayList<>();
    private List<String> names = new ArrayList<>();

    private void getData() {
        // 清空原有数据，重新加载新数据
        emptyData();

        imageIds.add(R.drawable.hall1);
        imageIds.add(R.drawable.hall2);

        names.add("大厅一");
        names.add("大厅二");

        for(int i = 0 ; i < imageIds.size() ; i++){                  //将数据添加到集合中
            hallArrayList.add(new Hall(imageIds.get(i),names.get(i)));  //将图片id和对应的name存储到一起
        }
    }


    private void emptyData() {
        imageIds = new ArrayList<>();
        names = new ArrayList<>();
        hallArrayList = new ArrayList<>();
    }

//    @Override
//    public boolean onCreateOptionsMenu(Menu menu) {
//        getMenuInflater().inflate(R.menu.main, menu);
//        return true;
//    }
}
