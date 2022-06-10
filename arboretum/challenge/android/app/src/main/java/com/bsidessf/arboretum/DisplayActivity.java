package com.bsidessf.arboretum;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import android.util.Log;
import android.widget.Button;
import android.widget.ImageView;
import androidx.navigation.ui.AppBarConfiguration;
import com.bsidessf.arboretum.databinding.ActivityDisplayBinding;
import com.squareup.picasso.Picasso;


public class DisplayActivity extends AppCompatActivity {

    private AppBarConfiguration appBarConfiguration;
    private ActivityDisplayBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityDisplayBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        setSupportActionBar(binding.toolbar);

        // Process Shortlink
        String shortLink = getIntent().getStringExtra("shortLink");
        ImageView imageView = findViewById(R.id.imageView_display);
        //String serverAddr = "https://arboretum-e83f3dfd.challenges.bsidessf.net/get_image";
        //String url = serverAddr;
        String serverAddr = "https://arboretum-e83f3dfd.challenges.bsidessf.net/";
        String serverPath = "/get-nft";
        String urlParam = "?url=";
        String url = serverAddr + serverPath + urlParam + shortLink;
        Log.d("Fetching url:", url);
        Picasso.get().load(url).into(imageView);

    }
}