import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/utils/image_factory.dart';
import 'package:pibro/utils/view_utils.dart';

class RotatedContainer extends StatefulWidget {
  const RotatedContainer({
    super.key,
    required this.text,
    required this.image,
    this.hasBoxShadow = true,
    this.borderColor = AppColors.primaryColor,
    this.backgroundColor = AppColors.white,
    this.isRotated = true,
    this.onPressed,
  });

  final String text;
  final String image;
  final bool hasBoxShadow;
  final Color borderColor;
  final Color backgroundColor;
  final bool isRotated;
  final Function()? onPressed;

  @override
  State<RotatedContainer> createState() => _RotatedContainerState();
}

class _RotatedContainerState extends State<RotatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    if (widget.isRotated) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      )..repeat(reverse: true);

      _animation = Tween<double>(begin: 0.97, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.isRotated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget rotatedWidget = GestureDetector(
      onTap: widget.onPressed ?? () {},
      child: SizedBox(
        // height: queryHeight(context) * 0.135,
        // width: queryHeight(context) * 0.135,
        height: 120,
        width: 120,
        child: Stack(
          children: [
            Transform.rotate(
              angle: widget.isRotated ? 150 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  border: Border.all(color: widget.borderColor, width: 3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: widget.hasBoxShadow
                      ? [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(-4, 4),
                            blurRadius: 4,
                          )
                        ]
                      : [],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageFactory.getImage(widget.image).render(height: 25),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.text,
                    style: Styles.boldTextStyle(size: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
    return widget.isRotated
        ? AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                // offset: Offset(0, _animation.value),
                scale: _animation.value,
                child: child,
              );
            },
            child: rotatedWidget,
          )
        : rotatedWidget;
  }
}
