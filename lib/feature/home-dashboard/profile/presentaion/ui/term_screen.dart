import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';

class TermScreen extends StatelessWidget {
  final int from;
  final String title;

  const TermScreen({super.key, required this.from, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, title),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* image
            Image.asset(
              from != 2
                  ? AssetImages.img_term_condition
                  : AssetImages.imng_term_condition_logistics,
            ),

            //* condition
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'condition'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'policy_title'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  //* condition ticket
                  if (from == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //1
                        const SizedBox(height: 10),
                        _buildTitle('1'),
                        const SizedBox(height: 5),
                        _buildBulletRow('1.1'),
                        _buildBulletRow('1.2'),
                        _buildBulletRow('1.3'),
                        _buildBulletRow('1.4'),
                        const SizedBox(height: 10),

                        //2
                        _buildTitle('2'),
                        const SizedBox(height: 5),
                        _buildBulletRow('2.1'),
                        _buildBulletRow('2.2'),
                        _buildBulletRow('2.3'),
                        _buildBulletRow('2.4'),
                        _buildBulletRow('2.5'),
                        _buildBulletRow('2.6'),
                        _buildBulletRow('2.7'),
                        const SizedBox(height: 10),

                        //3
                        _buildTitle('3'),
                        const SizedBox(height: 5),
                        _buildBulletRow('3.1'),
                        _buildBulletRow('3.2'),
                        _buildBulletRow('3.3'),
                        _buildBulletRow('3.4'),
                        _buildBulletRow('3.5'),
                        const SizedBox(height: 10),

                        //4
                        _buildTitle('4'),
                        const SizedBox(height: 5),
                        _buildBulletRow('4.1'),
                        _buildBulletRow('4.2'),
                        _buildBulletRow('4.3'),
                        const SizedBox(height: 10),

                        //5
                        _buildTitle('5'),
                        const SizedBox(height: 5),
                        _buildBulletRow('5.1'),
                        _buildBulletRow('5.2'),
                        _buildBulletRow('5.3'),
                        _buildBulletRow('5.4'),
                        const SizedBox(height: 10),

                        //6
                        _buildTitle('6'),
                        const SizedBox(height: 5),
                         _buildBulletRow('6.1', isStar: true),
                          Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBulletRow('6.1.1'),
                              _buildBulletRow('6.1.2'),
                              _buildBulletRow('6.1.3'),
                              _buildBulletRow('6.1.4'),
                            ],
                          ),
                        ),
                         _buildBulletRow('6.2'),
                         _buildBulletRow('6.3'),
                         _buildBulletRow('6.4'),
                        
                        const SizedBox(height: 10),

                        //7
                        const SizedBox(height: 10),
                        _buildTitle('7'),
                        const SizedBox(height: 5),
                        _buildBulletRow('7.1'),
                        _buildBulletRow('7.2'),
                        _buildBulletRow('7.3'),
                        _buildBulletRow('7.4'),
                        const SizedBox(height: 10),

                        //8
                         _buildTitle('8'),
                        const SizedBox(height: 5),
                         _buildBulletRow('8.1', isStar: true),
                          Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBulletRow('8.1.1'),
                              _buildBulletRow('8.1.2'),
                              _buildBulletRow('8.1.3'),
                              _buildBulletRow('8.1.4'),
                              _buildBulletRow('8.1.5'),
                              _buildBulletRow('8.1.6'),
                              _buildBulletRow('8.1.7'),
                            ],
                          ),
                        ),
                         _buildBulletRow('8.2'),
                       
                        const SizedBox(height: 10),

                        //9
                        _buildTitle('9'),
                        const SizedBox(height: 5),
                        _buildBulletRow('9.1'),
                        _buildBulletRow('9.2'),
                        _buildBulletRow('9.3'),
                        const SizedBox(height: 10),

                         //10
                        _buildTitle('10'),
                        const SizedBox(height: 5),
                        _buildBulletRow('10.1'),
                        _buildBulletRow('10.2'),
                        _buildBulletRow('10.3'),
                        _buildBulletRow('10.4'),
                        const SizedBox(height: 10),

                        //10
                        _buildTitle('11'),
                        const SizedBox(height: 5),
                        _buildBulletRow('11.1'),
                        _buildBulletRow('11.2'),
                        _buildBulletRow('11.3'),
                        const SizedBox(height: 10),

                         //10
                        _buildTitle('12'),
                        const SizedBox(height: 5),
                        _buildBulletRow('12.1'),
                        _buildBulletRow('12.2'),
                        _buildBulletRow('12.3'),
                        _buildBulletRow('12.4'),
                        _buildBulletRow('12.5'),
                        const SizedBox(height: 10),

                        //10
                        _buildTitle('13'),
                        const SizedBox(height: 5),
                        _buildBulletRow('13.1'),
                        _buildBulletRow('13.2'),
                        _buildBulletRow('13.3'),
                        _buildBulletRow('13.4'),
                        const SizedBox(height: 10),

                        //10
                        _buildTitle('14'),
                        const SizedBox(height: 5),
                        _buildBulletRow('14.1'),
                        const SizedBox(height: 10),
                      ],
                    ),

                  //* condition logistics
                  if (from == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildBulletRow('t1'),
                        const SizedBox(height: 10),
                        _buildBulletRow('t2'),
                        const SizedBox(height: 10),
                        _buildBulletRow('t3'),
                        const SizedBox(height: 10),
                        _buildBulletRow('t4'),
                        const SizedBox(height: 10),
                        _buildBulletRow('t5'),
                        const SizedBox(height: 10),
                        _buildBulletRow('t6'),
                      ],
                    ),

                  //* condition buva sea
                  if (from == 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //1
                        const SizedBox(height: 10),
                        _buildTitle('b1'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b11'),
                        _buildBulletRow('b12'),
                        _buildBulletRow('b13'),
                        const SizedBox(height: 10),

                        //2
                        _buildTitle('b2'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b21'),
                        _buildBulletRow('b22'),
                        const SizedBox(height: 10),

                        //3
                        _buildTitle('b3'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b31'),
                        _buildBulletRow('b32'),
                        _buildBulletRow('b33'),
                        const SizedBox(height: 10),

                        //4
                        _buildTitle('b4'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b40', isStar: true),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBulletRow('b41'),
                              _buildBulletRow('b42'),
                              _buildBulletRow('b43'),
                              _buildBulletRow('b44'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        //5
                        _buildTitle('b5'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b51'),
                        const SizedBox(height: 10),

                        //6
                        _buildTitle('b6'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b61'),
                        _buildBulletRow('b62'),
                        const SizedBox(height: 10),

                        //7
                        _buildTitle('b7'),
                        const SizedBox(height: 5),
                        _buildBulletRow('b71'),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String textKey) {
    return Text(
      textKey.tr,
      style: const TextStyle(fontSize: 14, color: AppColors.titleColor),
    );
  }

  Widget _buildBulletRow(String textKey, {bool isStar = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isStar ? const Icon(Ionicons.star, size: 10) : const Text("•"),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            textKey.tr,
            style: const TextStyle(fontSize: 14, color: AppColors.textColor),
          ),
        ),
      ],
    );
  }
}
