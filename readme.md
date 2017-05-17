##项目背景

在实际开发中，产品对刷新的视觉效果越来越高，最常见的就是动画效果。
本项目继承MJRefresh，让上拉，下拉，更好的自定义动画效果。


##支持pod


``` swift
pod "LARefresh"
```

##使用说明


``` swift
   self.tableView.mj_header = [LARefreshHeader headerWithRefreshingBlock:^{
       
    }];
    self.tableView.mj_footer = [LARefreshFooter footerWithRefreshingBlock:^{
          }];
```


##实际效果图

下拉加载效果图：
![](https://github.com/leoAntu/leoImagesStorage/blob/master/leoImagesStorage/32C91555-A22F-4F42-AA1C-8B3DFC0C3F07.png?raw=true)

下拉加载效果图：
![](https://github.com/leoAntu/leoImagesStorage/blob/master/leoImagesStorage/E4D3AE16-88C8-4617-AF37-C0BE82CBD8CA.png?raw=true)

加载完毕效果图：
![](https://github.com/leoAntu/leoImagesStorage/blob/master/leoImagesStorage/QQ20170517-0.png?raw=true)



##自定义图片


将图片放入Bundle文件夹即可。

