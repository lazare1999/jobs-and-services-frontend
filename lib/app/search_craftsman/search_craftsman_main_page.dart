import 'dart:async';

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

import '../main_menu.dart';

class SearchCraftsmanMainPage extends StatefulWidget {
  const SearchCraftsmanMainPage({Key? key}) : super(key: key);

  @override
  _SearchCraftsmanMainPage createState() => _SearchCraftsmanMainPage();
}

class _SearchCraftsmanMainPage extends State<SearchCraftsmanMainPage> {

  static const _pageSize = 10;
  bool _searchOnlyFavorite = false;
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
                          Expanded(
                            child: ListTile(
                              title: const Icon(Icons.phone, color: Colors.green),
                              onTap: () {
                                launch('tel:' + item.username!);
                              },
                            ),
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
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn1",
              child: Icon(_searchOnlyFavorite ? Icons.star : Icons.star_border_outlined),
              onPressed: () {
                setState(() {
                  _searchOnlyFavorite = !_searchOnlyFavorite;
                  _pagingController.refresh();
                });
              },
            ),
            FloatingActionButton(
              heroTag: "btn2",
              child: const Icon(Icons.search),
              onPressed: () {
                _pagingController.refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}