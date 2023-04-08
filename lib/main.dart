import 'dart:convert';
import 'package:image_network/image_network.dart';
import 'package:flutter/material.dart';
// import 'package:visual_gpt/constants.dart';
import 'package:http/http.dart' as http;
import 'model.dart';
import 'dart:html' as html;
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'VisualGPT',
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const userBgColor = Color(0xff343541);
const botBgColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool? isLoading;
  TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponse(String prompt) async {
    const apiKey = "<YOUR OPENAI API KEY>";
    var url = Uri.https("api.openai.com", "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': '$prompt\n',
        'temperature': 0.7,
        'max_tokens': 2000,
        'top_p': 1,
        'frequency_penalty': 0,
        'presence_penalty': 0,
      }),
    );

    Map<String, dynamic> newResponse = jsonDecode(response.body);
    return newResponse['choices'][0]['text'].trim();
  }

  Future<String> generateImage(String input) async {
    const apiKey = "<YOUR OPENAI API KEY>";
    String url = 'https://api.openai.com/v1/images/generations';
    String? image;

    var data = {
      "prompt": input,
      "n": 1,
      "size": "512x512",
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey"
      },
      body: jsonEncode(data),
    );

    var jsonResponse = jsonDecode(response.body);

    image = jsonResponse["data"][0]["url"];
    print(image);

    return image!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset("assets/logo.png"),
          ),
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "VisualGPT",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("About the Developer"),
                        content: Container(
                          height: 150,
                          width: 250,
                          child: Column(
                            children: [
                              const Text(
                                  "Hi, I'm Ishan Kshirsagar. Follow me on social media to know more about me :"),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // two image buttons to open the developer's social media profiles
                                  IconButton(
                                    icon: Image.asset("assets/github.png"),
                                    iconSize: 50,
                                    onPressed: () {
                                      html.window.open(
                                          "https://github.com/ishan-kshirsagar0-7",
                                          "_blank");
                                    },
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  IconButton(
                                    icon: Image.asset("assets/linkedin.png"),
                                    iconSize: 50,
                                    onPressed: () {
                                      html.window.open(
                                          "https://www.linkedin.com/in/ishankshirsagar07/",
                                          "_blank");
                                    },
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  IconButton(
                                    icon: Image.asset("assets/instagram.png"),
                                    iconSize: 50,
                                    onPressed: () {
                                      html.window.open(
                                          "https://www.instagram.com/unpaired_electron0_7/",
                                          "_blank");
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
                tooltip: "About the Developer",
              ),
            )
          ],
          backgroundColor: botBgColor,
        ),
        backgroundColor: userBgColor,
        body: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading!,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          hintText: "Send your message...",
          hintStyle: TextStyle(
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
          fillColor: botBgColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading!,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
            child: Container(
              color: botBgColor,
              child: IconButton(
                tooltip: "Send Message",
                color: const Color.fromRGBO(142, 142, 160, 1),
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  setState(() {
                    _messages.add(
                      ChatMessage(
                          text: _textController.text,
                          chatMessageType: ChatMessageType.user,
                          isImage: false),
                    );
                    isLoading = true;
                  });
                  var input = _textController.text;
                  _textController.clear();
                  Future.delayed(
                    const Duration(milliseconds: 50),
                  ).then(
                    (value) => _scrollDown(),
                  );

                  generateResponse(input).then((value) {
                    setState(() {
                      isLoading = false;
                      _messages.add(
                        ChatMessage(
                            text: value,
                            chatMessageType: ChatMessageType.bot,
                            isImage: false),
                      );
                    });
                  });
                  _textController.clear();
                  Future.delayed(
                    const Duration(milliseconds: 50),
                  ).then(
                    (value) => _scrollDown(),
                  );
                },
              ),
            ),
          ),
          Container(
            color: botBgColor,
            child: IconButton(
              tooltip: "Generate Image",
              color: const Color.fromRGBO(142, 142, 160, 1),
              icon: const Icon(Icons.image),
              onPressed: () {
                isLoading = true;
                setState(() {
                  _messages.add(
                    ChatMessage(
                        text: _textController.text,
                        chatMessageType: ChatMessageType.user,
                        isImage: false),
                  );
                });
                var input = _textController.text;
                _textController.clear();
                Future.delayed(
                  const Duration(milliseconds: 50),
                ).then(
                  (value) => _scrollDown(),
                );
                generateImage(input).then((value) {
                  setState(() {
                    isLoading = false;
                    _messages.add(
                      ChatMessage(
                          text: value,
                          chatMessageType: ChatMessageType.bot,
                          isImage: true),
                    );
                  });
                });
                _textController.clear();
                Future.delayed(
                  const Duration(milliseconds: 50),
                ).then(
                  (value) => _scrollDown(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: ((context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
          isImage: message.isImage,
        );
      }),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  final bool isImage;

  const ChatMessageWidget(
      {super.key,
      required this.text,
      required this.chatMessageType,
      required this.isImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(10),
      color: chatMessageType == ChatMessageType.bot ? botBgColor : userBgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    // backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    child: Image.asset(
                      'assets/logo.png',
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: isImage
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 256,
                              width: 256,
                              child: ImageNetwork(
                                image: text,
                                height: 256,
                                width: 256,
                                duration: 1500,
                                curve: Curves.easeIn,
                                onPointer: true,
                                debugPrint: false,
                                fullScreen: false,
                                fitAndroidIos: BoxFit.cover,
                                fitWeb: BoxFitWeb.cover,
                                onLoading: const SpinKitWanderingCubes(
                                  color: Color.fromARGB(255, 35, 89, 182),
                                  size: 50.0,
                                ),
                                onError: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  debugPrint(
                                      "Devloped by\nLinkedIn : @ishankshirsagar07");
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 25),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(16, 163, 127, 1)),
                                  ),
                                  onPressed: () {
                                    html.window.open(text, "_blank");
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text("Open"),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 18),
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(16, 163, 127, 1)),
                                  ),
                                  onPressed: () {
                                    html.AnchorElement(href: text)
                                        .setAttribute("download", "image.png");
                                    html.document.body!.children
                                        .add(html.AnchorElement(href: text)
                                          ..setAttribute(
                                              "download", "image.png")
                                          ..click());
                                  },
                                  icon: const Icon(Icons.download),
                                  label: const Text("Download"),
                                ),
                              ],
                            )
                          ],
                        )
                      : Text(
                          text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white, fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
