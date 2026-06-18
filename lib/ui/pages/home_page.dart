import 'package:flutter/material.dart';
import 'package:taggery/ui/components/containers.dart';
import 'package:taggery/ui/components/media_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        
        Expanded(
          child: Pane(
            child: GridView.count(
              crossAxisCount: 4,
              children: List.generate(15, (index) {return MediaTile.thumbnailUnavailable();}).toList()
              ,
            )
          
          ),
        ),
        Expanded(
          child: Pane(child: SizedBox.expand(child: MediaTile.thumbnailUnavailable())),
        )
      ]),
    );
  }
}
