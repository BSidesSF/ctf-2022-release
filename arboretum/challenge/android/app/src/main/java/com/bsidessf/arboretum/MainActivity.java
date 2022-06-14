package com.bsidessf.arboretum;


import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;


import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.fragment.NavHostFragment;
import androidx.navigation.ui.AppBarConfiguration;
import androidx.navigation.ui.NavigationUI;

import com.bsidessf.arboretum.databinding.ActivityMainBinding;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.ShortDynamicLink;

import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;

import java.util.Random;

public class MainActivity extends AppCompatActivity {

    private AppBarConfiguration appBarConfiguration;
    private ActivityMainBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setSupportActionBar(binding.toolbar);
        Button requestButton = findViewById(R.id.button_main);
        requestButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // To-do release flag.png during launch event
                String baseUrl = "https://storage.cloud.google.com/arboretum-images-2022/tree";
                String fileExt = ".png";
                int min = 1;
                int max = 5;
                String id = String.valueOf(new Random().nextInt((max - min) + 1) + min);
                createShortLink(baseUrl + id + fileExt);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


    public void createShortLink(String url) {
        String shortLink;
        Log.d("Creating dynamic link for url:", url);
        Task<ShortDynamicLink> shortLinkTask = FirebaseDynamicLinks.getInstance().createDynamicLink()
                .setLink(Uri.parse(url))
                .setDomainUriPrefix("https://bsidessfctf2022.page.link")
                .buildShortDynamicLink()
                .addOnCompleteListener(this, new OnCompleteListener<ShortDynamicLink>() {
                    @Override
                    public void onComplete(@NonNull Task<ShortDynamicLink> task) {
                        if (task.isSuccessful()) {
                            // Short link created
                            String shortLink = task.getResult().getShortLink().toString();
                            Log.d("Dynamic link created:", shortLink);
                            Intent intent = new Intent(getBaseContext(), DisplayActivity.class);
                            intent.putExtra("shortLink", shortLink);
                            startActivity(intent);
                        }
                        else {
                            Log.d("Dynamic link creation failed:", task.getException().toString());
                        }
                    }
                });
        Log.d("Returning from createShortLink:","back we go");

    }
}