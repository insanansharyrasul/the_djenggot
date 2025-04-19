import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class TileView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;

  const TileView({super.key, this.titleTxt = "", this.subTxt = ""});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              titleTxt,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.5,
                color: AppTheme.lightText,
              ),
            ),
          ),
          // InkWell(
          //   highlightColor: Colors.transparent,
          //   borderRadius: BorderRadius.all(Radius.circular(4.0)),
          //   onTap: () {},
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 8),
          //     child: Row(
          //       children: <Widget>[
          //         Text(
          //           subTxt,
          //           textAlign: TextAlign.left,
          //           style: TextStyle(
          //             fontFamily: DjenggotAppTheme.fontName,
          //             fontWeight: FontWeight.normal,
          //             fontSize: 16,
          //             letterSpacing: 0.5,
          //             color: DjenggotAppTheme.nearlyDarkBlue,
          //           ),
          //         ),
          //         SizedBox(
          //           height: 38,
          //           width: 26,
          //           child: Icon(
          //             Icons.arrow_forward,
          //             color: DjenggotAppTheme.darkText,
          //             size: 18,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
