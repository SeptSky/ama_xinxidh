package com.amainfoindex

import android.os.Bundle
import android.os.Build
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
    {
      // API>21，设置状态栏颜色透明
      getWindow().setStatusBarColor(0);
    }
    GeneratedPluginRegistrant.registerWith(this)
  }
}
