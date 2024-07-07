import "package:flutter/material.dart";

class BottomSheetHandler extends StatelessWidget {
  const BottomSheetHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Align(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffc4c6d0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        width: 48,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
      ),
    );
  }
}
