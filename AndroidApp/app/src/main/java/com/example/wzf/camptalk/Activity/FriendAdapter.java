package com.example.wzf.camptalk.Activity;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.wzf.camptalk.R;

import java.util.List;

public class FriendAdapter extends ArrayAdapter<Friend> {
    private int resourceId;

    public FriendAdapter(Context context, int textViewResourceId, List<Friend> objects) {
        super(context, textViewResourceId, objects);
        resourceId = textViewResourceId;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder viewHolder;                  //实例ViewHolder，当程序第一次运行，保存获取到的控件，提高效率
        if(convertView == null){
            viewHolder = new ViewHolder();
            view = LayoutInflater.from(getContext()).inflate(//convertView为空代表布局没有被加载过，即getView方法没有被调用过，需要创建
                    resourceId, null);          // 得到子布局，非固定的，和子布局id有关
            viewHolder.ivImage = (ImageView) view.findViewById(R.id.ivImage);//获取控件,只需要调用一遍，调用过后保存在ViewHolder中
            viewHolder.tvName = (TextView) view.findViewById(R.id.tvName);   //获取控件
            view.setTag(viewHolder);
        }else{
            view=convertView;           //convertView不为空代表布局被加载过，只需要将convertView的值取出即可
            viewHolder=(ViewHolder) view.getTag();
        }

        Friend friend = getItem(position);//实例指定位置的水果

        viewHolder.ivImage.setImageResource(friend.getImageId());//获得指定位置水果的id
        viewHolder.tvName.setText(friend.getImageName());        //获得指定位置水果的名字
        return view;
    }
}
