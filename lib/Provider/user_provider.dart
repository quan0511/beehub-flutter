import 'package:beehub_flutter_app/Models/group.dart';
import 'package:beehub_flutter_app/Models/profile.dart';
import 'package:beehub_flutter_app/Models/user.dart';
import 'package:beehub_flutter_app/Utils/api_connection/http_client.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier{
  List<User> _friends = [];
  bool isLoading = false;
  List<Group> _groups = [];
  String? _username;
  Profile? profile;
  Group? _group;
  List<User> get friends {
    return _friends;
  }
  Future fetchFriends()async{
    isLoading = true;
    notifyListeners();
    List<User>? fetchUser= await THttpHelper.getListFriend();
    if(fetchUser!=null){
    _friends = fetchUser;
    isLoading=false;
    notifyListeners();
    }
  }
  List<Group> get groups {
    return _groups;
  }
  Future fetchGroups() async{
    isLoading = true;
    notifyListeners();
    List<Group>? listGr = await THttpHelper.getGroups();
    if(listGr!=null){
      _groups = listGr;
      isLoading = false;
      notifyListeners();
    }
  }
  Future getUsername() async{
    _username ??= await THttpHelper.getUsername();
    notifyListeners();
  }
  String? get username {
    return _username;
  }
  void setUsername(String usern){
    _username = usern;
  }
  Future fetchProfile(isUserLogin,{user=""})async{
    isLoading=true;
    notifyListeners();
    if(!isUserLogin){
      profile = await THttpHelper.getProfile(user);
      isLoading = false;
      notifyListeners();
    }else{
      profile = await THttpHelper.getProfile(username!);
      isLoading = false;
      notifyListeners();
    }
  }
  Group? get group{
    return _group;    
  }
  Future fetchGroup(num idGroup)async{
    isLoading = true;
    notifyListeners();
    Group? findGroup = await THttpHelper.getGroup(idGroup);
    _group = findGroup;
    isLoading = false;
    notifyListeners();
  }
}