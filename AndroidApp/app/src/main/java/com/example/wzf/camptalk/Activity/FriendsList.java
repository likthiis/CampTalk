package com.example.wzf.camptalk.Activity;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import com.example.wzf.camptalk.R;

import java.util.ArrayList;
import java.util.List;

public class FriendsList extends Fragment {

    private ListView friendList;

    private List<Friend> friendArrayList = new ArrayList<Friend>();


    private View view;

    private static final String TAG = FriendsList.class.getSimpleName();

    View mRootView;

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        view = inflater.inflate(R.layout.friends_list, container, false);
        return view;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        friendList = (ListView) view.findViewById(R.id.friendsList);

        getData();

        FriendAdapter friendAdapter = new FriendAdapter(this.getActivity(),
                R.layout.list_view, friendArrayList);

        friendList.setAdapter(friendAdapter);

        friendList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position,
                                    long id) {
                Friend friend=friendArrayList.get(position);         //获取点击的那一行
                Toast.makeText(FriendsList.this.getActivity(),friend.getImageName(),Toast.LENGTH_LONG).show();//使用吐司输出点击那行水果的名字
            }
        });

    }

    private List<Integer> imageIds = new ArrayList<>();
    private List<String> names = new ArrayList<>();

    private void getData() {
        emptyData();

        imageIds.add(R.drawable.hall1);
        imageIds.add(R.drawable.hall2);

        names.add("零度");
        names.add("零度二");

        for(int i = 0 ; i < imageIds.size() ; i++){                  //将数据添加到集合中
            friendArrayList.add(new Friend(imageIds.get(i),names.get(i)));  //将图片id和对应的name存储到一起
        }
    }

    private void emptyData() {
        imageIds = new ArrayList<>();
        names = new ArrayList<>();
        friendArrayList = new ArrayList<>();
    }

}
