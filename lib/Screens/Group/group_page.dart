import 'dart:ui';

import 'package:beehub_flutter_app/Constants/color.dart';
import 'package:beehub_flutter_app/Models/group.dart';
import 'package:beehub_flutter_app/Provider/user_provider.dart';
import 'package:beehub_flutter_app/Screens/Group/group_about.dart';
import 'package:beehub_flutter_app/Screens/Group/group_discussion.dart';
import 'package:beehub_flutter_app/Screens/Group/group_media.dart';
import 'package:beehub_flutter_app/Screens/Group/group_people.dart';
import 'package:beehub_flutter_app/Utils/api_connection/http_client.dart';
import 'package:beehub_flutter_app/Utils/beehub_button.dart';
import 'package:beehub_flutter_app/Utils/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});
  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int? _idGroup;
  List<String> tabs = [
    "Discussion",
    "About",
    "People",
    "Media"
  ];
  int currentTab =0;

  double changePositionedOfLine(){
    switch (currentTab) {
      case 0:
        return 0;
      case 1:
        return 90;
      case 2:
        return 150;
      case 3:
        return 218;
      default:
        return 0;
    }
  }
  double changeContainerWidth(){
    switch (currentTab) {
      case 0:
        return 80;
      case 1:
        return 50;
      case 2:
        return 55 ;
      case 3:
        return 50 ;
      default:
        return 0;
    }
  }
  Widget changeSection(tab){
      switch (tab) {
        case "Discussion":
          return const GroupDiscussion();
        case "About":
          return const GroupAbout();
        case "People":
          return const GroupPeople();
        case "Media":
          return  const GroupMedia();
        default:
          return const GroupDiscussion();
      }
  }
  @override
  void initState() {
    super.initState();
    _idGroup = Get.parameters["idGroup"]!=null? int.parse(Get.parameters["idGroup"]!): null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(_idGroup!=null){
        Provider.of<UserProvider>(context, listen: false).fetchGroup(_idGroup!);  
      }
    }); 
  }
  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<UserProvider>(context).isLoading;
    Group? group = Provider.of<UserProvider>(context).group;
    if(isLoading || group==null ||_idGroup==null){
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              TColors.buttonPrimary
            ),
          )
        ),
      );
    }
    Widget getButton(){
    
      if(group.joined==null){
        return BeehubButton.JoinGroup(group.id!, "/", null);
      }else if(group.joined=="send request"){
        return BeehubButton.CancelJoinGroup(group.id!, "/group/${group.id}", null);
      }else{
        switch (group.memberRole) {
          case "MEMBER":
            return BeehubButton.LeaveGroup(group.id!, "/group/${group.id}", null);
          case "GROUP_CREATOR":
            return BeehubButton.ManagerGroup(group.id!);
          case "GROUP_MANAGER":
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BeehubButton.ManagerGroup(group.id!),
                const SizedBox(width: 8,),
                BeehubButton.LeaveGroup(group.id!, '/group/${group.id}', null)
              ],
            );
          default:
            return BeehubButton.JoinGroup(group.id!, "/",null);
        }
      }
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: Colors.white,
            elevation: 0.0,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                    color:TColors.darkerGrey,
                    child: group.backgroundGroup!=null && group.backgroundGroup!.isNotEmpty? Image.network(group.backgroundGroup!): const SizedBox(),
                    ),
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground
              ],
            ),
            leadingWidth: 80,
            leading: Container(
              margin: const EdgeInsets.only(left:24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(56),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.20)
                    ),
                    child: IconButton(
                      onPressed: ()=>Get.toNamed("/"), 
                      icon:const Icon(Icons.chevron_left)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              width: THelperFunction.screenWidth(),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black,width: 1.0),
                              borderRadius: BorderRadius.circular(35.0),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: group.imageGroup !=null&&group.imageGroup!.isNotEmpty? NetworkImage(group.imageGroup!):
                              const AssetImage("assets/avatar/group_image.png") as ImageProvider)
                            ),
                            width: 70,
                            height: 70,
                            child: const SizedBox()
                              
                          ), 
                          Container(
                            width: 160,
                            padding: const EdgeInsets.only(left: 10),
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(group.groupname, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6,),
                                Text(group.publicGroup? "Public Group":"Private Group", style: Theme.of(context).textTheme.labelMedium!)
                              ],)
                            ),
                          
                        ],
                      ),
                      getButton()
                    ],
                  ),
                  const SizedBox(height: 10,),
                   Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(group.description!)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                    child: Text("Created at ${DateFormat.yMMMMd('en_US').format(group.createdAt!)}"),
                  ),
                  SizedBox(
                    width: THelperFunction.screenWidth(),
                    height: THelperFunction.screenHeight()*0.05,
                    child: Stack(children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          width: THelperFunction.screenWidth(),
                          height: THelperFunction.screenHeight() * 0.04,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: tabs.length,
                            itemBuilder: (context,index){
                              return GestureDetector(
                                onTap: (){
                                  setState(() {
                                    currentTab = index;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left:index==0?10:22,
                                    top: 7),
                                  child: Text(tabs[index],style: GoogleFonts.ubuntu(
                                    fontSize: currentTab==index? 16:14,
                                    fontWeight: currentTab==index?FontWeight.w400: FontWeight.w300),),
                                ),
                              );
                            }),
                        ),
                      ),
                      AnimatedPositioned(
                        bottom: 0,
                        left: changePositionedOfLine(),
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedContainer(
                          curve: Curves.fastLinearToSlowEaseIn,
                          margin: const EdgeInsets.only(left: 10),
                          duration:const Duration(milliseconds: 500),
                          width: changeContainerWidth(),
                          height: THelperFunction.screenHeight()*0.008,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: TColors.primary),
                          ),
                      )
                    ],)
                  ),    
                ],
              ),
            ),
          ),
          changeSection(tabs[currentTab])
          // SliverToBoxAdapter(
          //   child:   
          // )
        ]
      ),
    );
  }
}