import 'package:flutter/material.dart';

class AlertDialogNoInternet extends StatefulWidget {
  const AlertDialogNoInternet({
    super.key,
    required this.ani,
    required this.title,
    required this.description,
  });

  final String title, description, ani;

  @override
  State<AlertDialogNoInternet> createState() => _AlertDialogNoInternetState();
}

class _AlertDialogNoInternetState extends State<AlertDialogNoInternet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.red[800]!.withValues(alpha: 0.9),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Image.asset(widget.ani, width: 44, height: 44),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(widget.description, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
