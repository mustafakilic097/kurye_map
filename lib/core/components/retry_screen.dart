import 'package:flutter/material.dart';

class RetryScreen extends StatelessWidget {
  final Widget routeWidget;
  const RetryScreen({Key? key, required this.routeWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(child: Icon(Icons.signal_wifi_bad_sharp, size: 25)),
        const Padding(
            padding: EdgeInsets.all(40),
            child: Card(
                child: Text(
              "Bu, genellikle cihazınızın şu anda sağlıklı bir İnternet bağlantısı olmadığını gösterir.",
              textAlign: TextAlign.center,
            ))),
        Center(
          child: TextButton(
              onPressed: () async {
                await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => routeWidget));
              },
              child: const Text("🔄 Tekrar Yükle")),
        )
      ],
    ));
  }
}
