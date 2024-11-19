import 'package:chat_with_ai/providers/chat_provider.dart';
import 'package:chat_with_ai/screens/chat_history_screen.dart';
import 'package:chat_with_ai/screens/chat_screen.dart';
import 'package:chat_with_ai/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final PageController _pageController = PageController();
  List<Widget> screens = [
    ChatHistoryScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];
//  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      return Scaffold(
        body: PageView(
          controller: chatProvider.pageController,
          children: screens,
          onPageChanged: (index) {
            chatProvider.setCurrentIndex(newIndex: index);
            // setState(() {
            //   currentIndex = index;
            // });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: chatProvider.currentIndex,
            elevation: 0,
            onTap: (index) {
              chatProvider.setCurrentIndex(newIndex: index);
              chatProvider.pageController.jumpToPage(index);
              // setState(() {
              //   currentIndex = index;
              // });
              // _pageController.jumpToPage(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Chat History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ]),
      );
    });
  }
}
