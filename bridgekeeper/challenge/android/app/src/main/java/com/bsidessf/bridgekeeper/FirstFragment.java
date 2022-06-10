package com.bsidessf.bridgekeeper;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.navigation.fragment.NavHostFragment;

import com.bsidessf.bridgekeeper.databinding.FragmentFirstBinding;

public class FirstFragment extends Fragment {

    private FragmentFirstBinding binding;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {

        binding = FragmentFirstBinding.inflate(inflater, container, false);
        return binding.getRoot();

    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        EditText answerText = (EditText) getView().findViewById(R.id.answerText);
        TextView statusMsg = (TextView) getView().findViewById(R.id.solveStatus);
        binding.submitButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String answerStr = answerText.getText().toString();
                if(Util.validateAnswer(1, answerStr)) {
                    Log.d("Answer:", "Correct");
                    statusMsg.setText(R.string.correct);
                    savePrefs(answerStr);
                    FragmentManager fragmentManager = getParentFragmentManager();
                    fragmentManager.beginTransaction()
                            .setCustomAnimations(
                                    R.anim.slide_in,  // enter
                                    R.anim.fade_out  // exit
                            )
                            .replace(R.id.fragmentContainerView, SecondFragment.class, null)
                            .setReorderingAllowed(true)
                            .addToBackStack(null)
                            .commit();
                }
                else{
                    Log.d("Answer:","Incorrect");
                    statusMsg.setText(R.string.incorrect);
                    statusMsg.setTextColor(getResources().getColor(R.color.red));
                }
                }

        });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    private void savePrefs(String str){
        Context context = getActivity();
        SharedPreferences sharedPref = context.getSharedPreferences(
                getResources().getString(R.string.preference_file_key), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPref.edit();
        editor.clear();
        editor.putString(getString(R.string.first_level), str);
        editor.apply();
    }

}