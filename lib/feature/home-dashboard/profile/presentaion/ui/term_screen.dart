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

                  //* condition ticket
                  if (from == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //1
                        const SizedBox(height: 10),
                        Text(
                          '1'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '1.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '1.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //2
                        Text(
                          '2'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '2.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '2.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //3
                        Text(
                          '3'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '3.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '3.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '3.3'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '3.4'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //4
                        Text(
                          '4'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '4.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '4.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //5
                        Text(
                          '5'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Ionicons.star, size: 10),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '5.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '5.2'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '5.3'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '5.4'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '5.5'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        //6
                        Text(
                          '6'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '6.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '6.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //7
                        Text(
                          '7'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Ionicons.star, size: 10),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '7.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.2'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.3'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.4'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.5'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.6'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '7.7'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        //8
                        Text(
                          '8'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '8.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '8.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //9
                        Text(
                          '9'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '9.1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '9.2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),

                  //* condition logistics
                  if (from == 2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't1'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't2'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't3'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't4'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't5'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                't6'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  //* condition buva sea
                  if (from == 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //1
                        const SizedBox(height: 10),
                        Text(
                          'b1'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b11'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b12'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b13'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //2
                        Text(
                          'b2'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b21'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b22'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //3
                        Text(
                          'b3'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b31'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b32'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b33'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //4
                        Text(
                          'b4'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Ionicons.star, size: 10),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b40'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'b41'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'b42'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'b43'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("•"),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'b44'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        //5
                        Text(
                          'b5'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b51'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //6
                        Text(
                          'b6'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b61'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b62'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        //7
                        Text(
                          'b7'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("•"),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'b71'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
