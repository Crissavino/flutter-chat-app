import 'package:flutter/material.dart';

class BotonAzul extends StatelessWidget {
  final String btnLabel;
  final Function onPressed;

  const BotonAzul({Key key, @required this.btnLabel, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: this.onPressed,
      elevation: 2,
      highlightElevation: 5,
      color: Colors.blue,
      shape: StadiumBorder(),
      child: Container(
        width: double.infinity,
        height: 55.0,
        child: Center(
          child: Text(
            this.btnLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.0,
            ),
          ),
        ),
      ),
    );
  }
}
