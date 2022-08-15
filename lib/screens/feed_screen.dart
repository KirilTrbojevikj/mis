import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:produck/utils/colors.dart';
import 'package:produck/utils/global_variable.dart';
import 'package:produck/widgets/post_card.dart';
import 'add_post_screen.dart';
import 'package:produck/responsive/mobile_screen_layout.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: width > webScreenSize ? webBackgroundColor : appBarColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: secondaryColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/produck-logo.svg',
                height: 60,
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.add_card),
                  tooltip: 'Add review',
                  onPressed:  ()  {
                     Navigator.push(context, MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return const Card(
                          color: orangeColor,
                          elevation: 0,
                          clipBehavior: Clip.none,
                          child: AddPostScreen(),
                        );
                      },
                    ));
                  },
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: width > webScreenSize ? width * 0.3 : 0,
                vertical: width > webScreenSize ? 15 : 0,
              ),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
      ),
    );
  }
}
