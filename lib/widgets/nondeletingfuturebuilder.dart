import 'package:flutter/material.dart';

class nonDeletingFutureBuilder extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const nonDeletingFutureBuilder({Key key, this.future, this.builder})
      : super(key: key);
  @override
  _nonDeletingFutureBuilderState createState() =>
      _nonDeletingFutureBuilderState();
}

class _nonDeletingFutureBuilderState extends State<nonDeletingFutureBuilder>
    with AutomaticKeepAliveClientMixin<nonDeletingFutureBuilder> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder,
    );
  }
}
