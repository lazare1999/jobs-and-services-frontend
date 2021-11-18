import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/info/info.dart';
import 'package:jobs_and_services/app/commons/models/users_info_model.dart';
import 'package:jobs_and_services/app/commons/star_rating.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../main_menu.dart';
import 'model/paid_users_model.dart';

class SearchCraftsmanMainPage extends StatefulWidget {
  const SearchCraftsmanMainPage({Key? key}) : super(key: key);

  @override
  _SearchCraftsmanMainPage createState() => _SearchCraftsmanMainPage();
}

class _SearchCraftsmanMainPage extends State<SearchCraftsmanMainPage> {

  static const _pageSize = 10;
  bool _searchOnlyFavorite = false;
  final HashMap<int, bool?> _wantToMakePaidMap = HashMap<int, bool?>();
  final List<PaidUsersModel> _users = List<PaidUsersModel>.empty(growable: true);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final PagingController<int, UsersInfoModel> _pagingController = PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {

    if (pageKey >0) {
      pageKey = pageKey - _pageSize +1;
    }

    try {

      final res = await jobsAndServicesClient.post(
        'craftsman/all_users',
        queryParameters: {
          "pageKey": pageKey.toString(),
          "pageSize": _pageSize.toString(),
          "searchOnlyFavorite": _searchOnlyFavorite.toString(),
        },
      );

      if(res.statusCode ==200) {
        List<UsersInfoModel> newItems = List<UsersInfoModel>.from(res.data.map((i) => UsersInfoModel.fromJson(i)));


        int j=0;
        if (_wantToMakePaidMap.isNotEmpty) {
          j = _wantToMakePaidMap.length;
        }
        for(int i=0; i < newItems.length; i++) {
          _wantToMakePaidMap[j] = false;
          var _model = PaidUsersModel();
          _model.updatePaidUsersModel(newItems[i], i);
          _users.add(_model);
          j++;
        }

        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }

      }

    } catch (e) {
      if (e is DioError && e.response?.statusCode == 403) {
        reloadApp(context);
      } else {
        _pagingController.error = e;
      }
      return;
    }

  }

  Future<bool> _onBackPressed(){
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainMenu()),
    ).then((x) => x ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { _onBackPressed(); },
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.info_outline,
            ),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          )
        ],
      ),
      endDrawer: Drawer(
          child: Info(
            //TODO : თარგმნე
            title: "მოძებნე მოხელე",
            safeAreaChild: ListView(
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.star, color: Colors.blueGrey),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("მხოლოდ ფავორიტებში ძებნა"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.add, color: Colors.blueGrey),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("გადაიხადე რომ დაუკავშირდე მოხელეს"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.search, color: Colors.blueGrey),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("მოძებნე მოხელე დეტალურად"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.phone, color: Colors.green),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("დაურეკე მოხელეს"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.email, color: Colors.redAccent),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("მიწერე მოხელეს"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.star, color: Colors.green),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("დაამატე ფავორიტებში"),
                          )
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: const <Widget>[
                      Icon(Icons.star_border_outlined, color: Colors.red),
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            //TODO : თარგმნე
                            child: Text("ამოშალე ფავორიტებიდან"),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => {
          _pagingController.refresh(),
          _wantToMakePaidMap.clear(),
          _users.clear(),
        }),
        child: PagedListView<int, UsersInfoModel>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<UsersInfoModel>(
            itemBuilder: (context, item, index) {

              var _firstLastName = (item.firstName ?? "") + " " + (item.lastName ==null ? "" : item.lastName!) + " " + (item.mainNickname ==null ? "" : item.mainNickname!);
              _firstLastName = item.username! + "  " + _firstLastName;
              if (item.nickname !=null && item.nickname!.isNotEmpty) {
                _firstLastName = item.nickname!;
              }

              return generateCard(
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          !item.isPaid! ? Flexible(
                            child: CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              value: _wantToMakePaidMap[index],
                              onChanged: (newValue) {
                                setState(() {
                                  _wantToMakePaidMap.update(index, (value) => newValue);
                                });
                              },
                            )
                          ): Visibility(
                            visible: false, child: Container(),
                          ),
                          item.isPaid! ? Expanded(
                            child: ListTile(
                              title: const Icon(Icons.phone, color: Colors.green),
                              onTap: () {
                                //TODO : შეამოწმე არის თუ არა გადახდილი მოცემული დღის მდგომარეობით (ჯერ აქ და მერე სერვერზე)
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        item.firstName!+" "+item.lastName!,
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: item.username,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.email),
                                            ),
                                          ),
                                          Expanded(
                                            child: MaterialButton(
                                              child: const Icon(Icons.phone, color: Colors.green,),
                                              onPressed: () {
                                                launch('tel:' + item.username!);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: const BorderSide(color: Colors.black)
                                      ),
                                    );
                                  },
                                );


                              },
                            ),
                          ): Visibility(
                            visible: false, child: Container(),
                          ),
                          item.isPaid! ? Expanded(
                            child: ListTile(
                              title: const Icon(Icons.email, color: Colors.redAccent),
                              onTap: () {
                                //TODO : შეამოწმე არის თუ არა გადახდილი მოცემული დღის მდგომარეობით (ჯერ აქ და მერე სერვერზე)

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        item.firstName!+" "+item.lastName!,
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextFormField(
                                              readOnly: true,
                                              initialValue: item.email,
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.email),
                                            ),
                                          ),
                                          Expanded(
                                            child: MaterialButton(
                                              child: const Icon(Icons.email, color: Colors.redAccent,),
                                              onPressed: () {
                                                launch('mailto:' + item.email!);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                          side: const BorderSide(color: Colors.black)
                                      ),
                                    );
                                  },
                                );


                              },
                            ),
                          ): Visibility(
                            visible: false, child: Container(),
                          ),
                          Expanded(
                            flex: 3,
                            child: ListTile(
                              title: Text(
                                _firstLastName,
                                style: TextStyle(
                                  color: item.isFav! ? Colors.blueGrey : Colors.black,
                                ),
                              ),
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 200,
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            MaterialButton(
                                              //TODO : თარგმნე
                                              child: const Text("კვალიფიკაცია"),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => const AlertDialog(
                                                      content: Text("აქ იქნება დეტალურად კვალიფიკაცია")
                                                    )
                                                );
                                              },
                                            ),
                                            MaterialButton(
                                              child: Text(AppLocalizations.of(context)!.rating),
                                              onPressed: () {

                                                showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      content: Form(
                                                        child: Scrollbar(
                                                          child: SingleChildScrollView(
                                                            padding: const EdgeInsets.all(16),
                                                            child: Column(
                                                              children: [
                                                                ...[
                                                                  StarRating(rating: item.rating ?? 0),
                                                                ].expand(
                                                                      (widget) => [
                                                                    widget,
                                                                    const SizedBox(
                                                                      height: 25,
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                );
                                              },
                                            ),
                                            !item.isFav! ? Container() : MaterialButton(
                                              child: Text(AppLocalizations.of(context)!.give_name),
                                              onPressed: () async {

                                                var _nickname = item.nickname;
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      content: Form(
                                                        child: Scrollbar(
                                                          child: SingleChildScrollView(
                                                            padding: const EdgeInsets.all(16),
                                                            child: Column(
                                                              children: [
                                                                ...[
                                                                  TextFormField(
                                                                    decoration: InputDecoration(
                                                                      filled: true,
                                                                      labelText: AppLocalizations.of(context)!.give_name,
                                                                    ),
                                                                    initialValue: item.nickname,
                                                                    onChanged: (value) {
                                                                      _nickname = value;
                                                                    },
                                                                  ),
                                                                  MaterialButton(
                                                                      color: Colors.blueGrey,
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(18.0),
                                                                      ),
                                                                      child: Text(
                                                                        AppLocalizations.of(context)!.save,
                                                                        style: const TextStyle(color: Colors.white),
                                                                      ),
                                                                      onPressed: () async {
                                                                        try {

                                                                          final res = await jobsAndServicesClient.post(
                                                                            'craftsman/update_nickname',
                                                                            queryParameters: {
                                                                              "favUserId": item.userId.toString(),
                                                                              "nickname": _nickname.toString(),
                                                                            },
                                                                          );

                                                                          if(res.statusCode ==200) {
                                                                            Navigator.pop(context,false);
                                                                            Navigator.pop(context,false);
                                                                            _pagingController.refresh();
                                                                          }

                                                                        } catch (e) {
                                                                          if (e is DioError && e.response?.statusCode == 403) {
                                                                            reloadApp(context);
                                                                          } else {
                                                                            showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
                                                                          }
                                                                          return;
                                                                        }
                                                                      }
                                                                  )
                                                                ].expand(
                                                                      (widget) => [
                                                                    widget,
                                                                    const SizedBox(
                                                                      height: 25,
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: MaterialButton(
                              child: Icon(
                                  item.isFav! ? Icons.star_border_outlined : Icons.star,
                                  color: item.isFav! ? Colors.red : Colors.green
                              ),
                              onPressed: () async {
                                if (item.isFav!) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(' '),
                                        content: Text(AppLocalizations.of(context)!.unmake_favorite_question),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: Text(AppLocalizations.of(context)!.yes),
                                            onPressed: () async {
                                              try {

                                                final res = await jobsAndServicesClient.post(
                                                  'craftsman/remove_favorite',
                                                  queryParameters: {
                                                    "favoriteUserId": item.userId.toString(),
                                                  },
                                                );

                                                if(res.statusCode ==200) {
                                                  _pagingController.refresh();
                                                  Navigator.pop(context,false);
                                                }

                                              } catch (e) {
                                                if (e is DioError && e.response?.statusCode == 403) {
                                                  reloadApp(context);
                                                } else {
                                                  _pagingController.error = e;
                                                }
                                                return;
                                              }
                                            }, //exit the app
                                          ),
                                          OutlinedButton(
                                            child: Text(AppLocalizations.of(context)!.no),
                                            onPressed: ()=> Navigator.pop(context,false),
                                          )
                                        ],
                                      )
                                  );
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(' '),
                                        content: Text(AppLocalizations.of(context)!.make_favorite_question),
                                        actions: <Widget>[
                                          OutlinedButton(
                                            child: Text(AppLocalizations.of(context)!.yes),
                                            onPressed: () async {
                                              try {

                                                final res = await jobsAndServicesClient.post(
                                                  'craftsman/add_user_in_favorites',
                                                  queryParameters: {
                                                    "favoriteUserId": item.userId.toString(),
                                                  },
                                                );

                                                if(res.statusCode ==200) {
                                                  _pagingController.refresh();
                                                  Navigator.pop(context,false);
                                                }

                                              } catch (e) {
                                                if (e is DioError && e.response?.statusCode == 403) {
                                                  reloadApp(context);
                                                } else {
                                                  _pagingController.error = e;
                                                }
                                                return;
                                              }
                                            }, //exit the app
                                          ),
                                          OutlinedButton(
                                            child: Text(AppLocalizations.of(context)!.no),
                                            onPressed: ()=> Navigator.pop(context,false),
                                          )
                                        ],
                                      )
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                  ), 10.0
              );
            },
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 30.0,
            ),
            Expanded(
              child: FloatingActionButton(
                heroTag: "btn1",
                child: Icon(_searchOnlyFavorite ? Icons.star : Icons.star_border_outlined),
                onPressed: () {
                  setState(() {
                    _searchOnlyFavorite = !_searchOnlyFavorite;
                    _pagingController.refresh();
                  });
                },
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: FloatingActionButton(
                heroTag: "btn2",
                child: const Icon(Icons.add),
                onPressed: () async {
                  List<int?> _checkedUsers = List<int?>.empty(growable: true);
                  _wantToMakePaidMap.forEach((key, value) {
                    if (value!) {
                      _checkedUsers.add(_users.where((c) => c.id == key).first.userId);
                    }
                  });

                  var _continue = true;
                  var _tariff = 0.0;
                  var _currency = "GEL";

                  if (_checkedUsers.isEmpty) {
                    //TODO : თარგმნე
                    showAlertDialog(context, "მონიშნეთ მომხმარებლები", "ყურადღება");
                    return;
                  }

                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text(' '),
                        content: const Text("გსურთ ტარიფის გაგება?"),
                        actions: <Widget>[
                          OutlinedButton(
                            child: Text(AppLocalizations.of(context)!.yes),
                            onPressed: () async {

                              try {

                                final res = await jobsAndServicesClient.post(
                                  'craftsman/get_paid_users_tariff',
                                  queryParameters: {
                                    "checkedUsers": _checkedUsers.toString(),
                                  },
                                );

                                if(res.statusCode ==200) {
                                  _tariff = res.data;
                                  Navigator.pop(context,false);
                                }

                              } catch (e) {
                                if (e is DioError && e.response?.statusCode == 403) {
                                  reloadApp(context);
                                } else {
                                  showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
                                }
                                return;
                              }

                            }, //exit the app
                          ),
                          OutlinedButton(
                            child: Text(AppLocalizations.of(context)!.no),
                            onPressed: () {
                              Navigator.pop(context,false);
                              _continue = false;
                            }, //
                          )
                        ],
                      )
                  );

                  if(_continue) {
                    await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(' '),
                          //TODO : თარგმნე
                          content: Text("გადასახდელია " + _tariff.toString() + " " + _currency + "\n" + "გსურთ გადახდა?"),
                          actions: <Widget>[
                            OutlinedButton(
                              child: Text(AppLocalizations.of(context)!.yes),
                              onPressed: () async {

                                try {
                                  //TODO : მერე ნახე თუ შეიძლება პირდაპირ გადახდის მეთოდით ჩანაცვლება მაგრამ ჩვენ ბაზებში მაინც უნდა აღირიცხოს რომ გადახდა მოხდა
                                  final res = await jobsAndServicesClient.post(
                                    'craftsman/pay_for_users_contact_info',
                                    queryParameters: {
                                      "checkedUsers": _checkedUsers.toString(),
                                    },
                                  );

                                  Navigator.pop(context,false);

                                  if (res.data) {
                                    _pagingController.refresh();
                                  } else {
                                    //TODO : თარგმნე
                                    showAlertDialog(context, "მონიშნეთ მომხმარებლები", "ყურადღება");
                                  }

                                  _users.clear();
                                  _wantToMakePaidMap.clear();

                                } catch (e) {
                                  if (e is DioError && e.response?.statusCode == 403) {
                                    reloadApp(context);
                                  } else {
                                    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
                                  }
                                  return;
                                }

                              },
                            ),
                            OutlinedButton(
                              child: Text(AppLocalizations.of(context)!.no),
                              onPressed: () {
                                Navigator.pop(context,false);
                              }, //
                            )
                          ],
                        )
                    );
                  }
                  
                },
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Expanded(
              child:  FloatingActionButton(
                heroTag: "btn3",
                child: const Icon(Icons.search),
                onPressed: () {
                  _pagingController.refresh();
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}