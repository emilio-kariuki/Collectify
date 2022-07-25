import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatelessWidget {
  final String title;
  final String hint;
  final int? linesCount;
  final TextEditingController? controller;
  final Widget? widget;
  final TextInputType? inputType;
  final int? maxLength;
  const InputField(
      {Key? key,
      required this.title,
      required this.hint,
      this.controller,
      this.widget,
      this.linesCount,
      this.inputType,
      this.maxLength})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          Container(
            //height: 50,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                    child: TextFormField(
                  maxLength: maxLength,
                  keyboardType: inputType,
                  maxLines: linesCount,
                  autofocus: false,
                  cursorColor: Colors.grey,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                      ),
                    ),
                  ),
                )),
                widget == null
                    ? Container()
                    : Container(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: widget),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
