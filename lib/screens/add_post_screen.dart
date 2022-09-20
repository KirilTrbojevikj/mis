import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:produck/providers/user_provider.dart';
import 'package:produck/resources/firestore_methods.dart';
import 'package:produck/screens/feed_screen.dart';
import 'package:produck/utils/colors.dart';
import 'package:produck/utils/utils.dart';
import 'package:provider/provider.dart';
import '../widgets/text_field_input.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  double _rating = 3.5;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
        _productNameController.text,
        _locationController.text,
        _descriptionController.text,
        _file!,
        uid,
        _rating,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Added new review!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
                color: secondaryColor,
              ),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: secondaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text(
                'Add review',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: orangeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator(
                        color: orangeColor,
                      )
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 200.0,
                      width: 200.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.contain,
                            alignment: FractionalOffset.topCenter,
                            image: MemoryImage(_file!),
                          )),
                        ),
                      ),
                    ),
                    RatingBar(
                        initialRating: 3.5,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                            full: const Icon(Icons.star_rounded,
                                color: Colors.orange),
                            half: const Icon(
                              Icons.star_half_rounded,
                              color: Colors.orange,
                            ),
                            empty: const Icon(
                              Icons.star_outline_rounded,
                              color: Colors.orange,
                            )),
                        onRatingUpdate: (value) {
                          setState(() {
                            _rating = value;
                          });
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _productNameController,
                      style: const TextStyle(color: secondaryColor),
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 218, 154, 17),
                            ),
                          ),
                          hintStyle: TextStyle(color: Colors.black26),
                          hintText: "Enter product name"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _locationController,
                      style: const TextStyle(color: secondaryColor),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 218, 154, 17),
                          ),
                        ),
                        hintStyle: TextStyle(color: Colors.black26),
                        hintText: "Enter location",
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        style: const TextStyle(color: secondaryColor),
                        controller: _descriptionController,
                        cursorColor: secondaryColor,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 218, 154, 17),
                              ),
                            ),
                            hintText: "Write your review here...",
                            hintStyle: TextStyle(color: Colors.black26)),
                        maxLines: 10,
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}
