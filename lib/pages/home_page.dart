import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{

  int page = 1;
  List<Map> hotGoodsList = [];

  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  @override
  bool get wantKeepAlive => true;
  

  String homePageContent = '正在获取数据';

  @override
  void initState() {
    _getHotGoods();
    super.initState();
  }

  void _getHotGoods() async{
    var formPage = {'page':page};
    request('homePageBelowConten',formData: formPage).then((val){
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var formData = {'lon':'115.02932','lat':'35.76189'};
    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text('百姓生活+'),),
        body: FutureBuilder(
          future: request('homePageContent', formData: formData),
          builder: (context,snapshot){
            if(snapshot.hasData){
               var data = json.decode(snapshot.data.toString());
               List<Map> swiper = (data['data']['slides'] as List).cast();
               List<Map> navgator = (data['data']['category'] as List).cast();
               String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];
               String leaderImage = data['data']['shopInfo']['leaderImage'];
               String leaderPhone = data['data']['shopInfo']['leaderPhone'];
               List<Map> recommendList = (data['data']['recommend'] as List).cast();
               String floor1Title = data['data']['floor1Pic']['PICTURE_ADDRESS'];
               String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];
               String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];
               List<Map> floor1 = (data['data']['floor1'] as List).cast();
               List<Map> floor2 = (data['data']['floor2'] as List).cast();
               List<Map> floor3 = (data['data']['floor3'] as List).cast();

               return EasyRefresh(
                 refreshFooter: ClassicsFooter(
                   bgColor: Colors.white,
                   textColor: Colors.pink,
                   moreInfoColor: Colors.pink,
                   showMore: true,
                   noMoreText: '',
                   moreInfo: '加载中',
                   loadReadyText: '正在刷新',
                   loadText: '上拉加载',
                   key: _footerKey,
                 ),

                 child: ListView(
                   children: <Widget>[
                     SwipeDiy(swipeDataList:swiper),
                     TopNavigator(navigatorList:navgator),
                     AdBanner(adPicture:adPicture),
                     LeaderPhone(leaderImage: leaderImage,leaderPhone: leaderPhone),
                     Recommend(recommendList: recommendList),
                     FloorTitle(picture_address:floor1Title),
                     FloorContent(floorGoodsList: floor1,),
                     FloorTitle(picture_address:floor2Title),
                     FloorContent(floorGoodsList: floor2,),
                     FloorTitle(picture_address:floor3Title),
                     FloorContent(floorGoodsList: floor3,),
                     hotGoods()
                   ],
                 ),
                 loadMore: ()async{
                   print('开始加载更多..............');
                   _getHotGoods();
               },
               );
            }else{
              return Center(
                child: Text('加载中......'),
              );
            }
          },
        )
      ),
    );
  }


  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(8.0),
    alignment: Alignment.center,
    color: Colors.transparent,
    child: Text('火爆专区'),
  );

  Widget _warpList(){
    if(hotGoodsList.length != 0){
      List<Widget> listWidget = hotGoodsList.map((val){
        return InkWell(
          onTap: (){},
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(val['image'],width: ScreenUtil().setWidth(370),),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.pink,fontSize: ScreenUtil().setSp(26)),
                ),
                Row(
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text(
                        '￥${val['price']}',
                      style: TextStyle(color: Colors.black26,decoration: TextDecoration.lineThrough),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget
      );
    }else {
      return Text('');
    }
  }

  Widget hotGoods(){
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _warpList()
        ],
      ),
    );
  }
}



//首页轮播组件
class SwipeDiy extends StatelessWidget {

  final List swipeDataList;

  SwipeDiy({this.swipeDataList});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context,int index){
          return Image.network("${swipeDataList[index]['image']}",fit: BoxFit.fill,);
        },
        itemCount: swipeDataList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

//导航栏
class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({this.navigatorList});

  Widget _gridViewItemUI(BuildContext context,item){
    return InkWell(
      onTap: (){
        print('点击了导航');
      },
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width: ScreenUtil().setWidth(95),),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if(navigatorList.length > 10){
      this.navigatorList.removeRange(10, navigatorList.length);
    }

    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),

      child: GridView.count(
        //屏蔽GridView内部滚动；
        physics: new NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item){
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

//广告区域
class AdBanner extends StatelessWidget {

  final String adPicture;
  AdBanner({this.adPicture});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicture),
    );
  }
}

//店长电话
class LeaderPhone extends StatelessWidget {
  final String leaderImage;//店长图片
  final String leaderPhone;//店长电话

  LeaderPhone({this.leaderImage,this.leaderPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launcherURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launcherURL() async{
    String url = 'tel:' + leaderPhone;
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw 'URL不能进行访问';
    }
  }
}

//商品推荐
class Recommend extends StatelessWidget {
  final List recommendList;
  Recommend({this.recommendList});

  //推荐商品标题
  Widget _titleWidget(){
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 0,5.0),
        decoration: BoxDecoration(
            color:Colors.white,
            border: Border(
                bottom: BorderSide(width:0.5,color:Colors.black12)
            )
        ),
        child:Text(
            '商品推荐',
            style:TextStyle(color:Colors.pink)
        )
    );
  }

  //商品条目
  Widget _item(index){
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration:BoxDecoration(
            color:Colors.white,
            border:Border(
                left: BorderSide(width:0.5,color:Colors.black12)
            )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color:Colors.grey
              ),
            )
          ],
        ),
      ),
    );
  }

  //横向列表
  Widget _recommendList(){

    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context,index){
          return _item(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommendList()
        ],
      ),
    );
  }
}

//楼层标题
class FloorTitle extends StatelessWidget {
  final String picture_address;

  FloorTitle({this.picture_address});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(picture_address),
    );
  }
}

//楼层商品列表
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({this.floorGoodsList});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods()
        ],
      ),
    );
  }

  Widget _firstRow(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(floorGoodsList[1]),
            _goodsItem(floorGoodsList[2]),
          ],
        )
      ],
    );
  }

  Widget _otherGoods(){
    return Row(
      children: <Widget>[
        _goodsItem(floorGoodsList[3]),
        _goodsItem(floorGoodsList[4]),
      ],
    );
  }

  Widget _goodsItem(Map goods){
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: (){},
        child: Image.network(goods['image']),
      ),
    );
  }
}








