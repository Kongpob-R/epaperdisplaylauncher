import 'dart:developer';

import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late String language;
  @override
  void initState() {
    super.initState();
    language = 'EN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About this device'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              log(language);
              if (language == 'EN') {
                setState(() {
                  language = 'TH';
                });
              } else {
                setState(() {
                  language = 'EN';
                });
              }
            },
            child: Text(
              language,
              style: const TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: AboutContent(language: language),
    );
  }
}

class AboutContent extends StatelessWidget {
  final String language;
  const AboutContent({Key? key, required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (language == 'TH') {
      return const Center(
        child: Text(
          """
เครื่องอ่านหนังสืออิเล็กทรอนิกส์นี้เป็นผลมาจากโครงงานปริญญานิพนธ์ 

"การพัฒนารูปแบบการใช้งานของเครื่องอ่านหนังสืออิเล็กทรอนิกส์เพื่อเป็นชั้นหนังสือสาธารณะ" 

เป็นส่วนหนึ่งของการศึกษาตามหลักสูตรวิศวกรรมศาสตรบัณฑิต
สาขาวิชาวิศวกรรมคอมพิวเตอร์ ภาควิชาวิศวกรรมไฟฟ้าและคอมพิวเตอร์
คณะวิศวกรรมศาสตร์ มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าพระนครเหนือ
ปีการศึกษา 2564

คณะผู้จัดทำ
ก้องภพ รักรุ่งโรจน์ รหัสนักศึกษา 6101012610029
วรศิริ คุณาภาเลิศ รหัสนักศึกษา 6101012630143

ที่ปรึกษา
ดร.ยืนยง นิลสยาม

คณะกรรมการโครงงาน
อ.โสภณ อภิรมย์วรการ
ดร.ดนุชา ประเสริฐสม
ดร.อรอุมา เทศประสิทธิ์

และขอขอบคุณความช่วยเหลือจาก
คุณจีระพล คุ้มเอี่ยม เจ้าหน้าที่ฝ่ายเทคโนโลยีสารสนเทศ สำนักหอสมุดกลาง ที่ช่วยประสานงานและให้คำปรึกษาจนโครงงานปริญญานิพนธ์นี้สำเร็จลุล่วง

ทรัพยากรหนังสืออิเล็กทรอนิกส์ทั้งหมด เป็นลิขสิทธ์ของ สำนักหอสมุกลาง มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าพระนครเหนือ
""",
          textAlign: TextAlign.center,
          textScaleFactor: 1.1,
        ),
      );
    } else {
      return const Center(
        child: Text(
          """
This e-book reader is the result of the project

"Interface of E-Reader Development for Public Bookshelf"

A partial fullfillment of the requierments for the degree of Bachelor of Computer Engineering
Department of Electrical and Computer Engineering
Faculty of Engineering
King Mongkut's University of Technology North Bangkok
Academic Year 2021

Project Member
Kongpob Rakrungroj ID. 6101012610029
Vorasiri Kunaphalert ID. 6101012630143

Project Advisor
Dr. Yuenyong Nilsiam

Project Committee
Sopon Apiromvorakarn
Dr. Danucha Prasertsom
Dr. Ornuma Thesprasith

Special Thanks to
Jeerapol Khumkeam
The Information Technology Officer of the Central Library 
who give assistance to the project

Copyright of all E-Book Resources belong to Central Library KMUTNB 
""",
          textAlign: TextAlign.center,
          textScaleFactor: 1.15,
        ),
      );
    }
  }
}
