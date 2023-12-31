import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/Docterdetail.dart';
import 'package:doctro/model/Timeslot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave/core/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../StripePaymentScreen.dart';
import '../const/prefConstatnt.dart';
import 'localization/preference.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';
import 'model/apply_offer.dart';
import 'model/bookappointments.dart';

enum SingingCharacter { Paypal, Razorpay, Stripe, FlutterWave, PayStack, COD }

class BookAppointment extends StatefulWidget {
  final int? id;

  BookAppointment({this.id});

  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  bool loading = false;

  late PlatformFile file;

  bool isPaymentClicked = false;
  String? _paymentToken = "";

  List<String> reportImages = [];

  // RazorPay //
  late Razorpay _razorpay;

  // FlutterWave //
  final String txRef = "";
  final String amount = "";
  final String currency = FlutterwaveCurrency.RWF;

  // Detail_Setting & Payment_Detail //
  String? businessName = "";
  String? logo = "";
  String? razorpayKey = "";
  int? cod = 0;
  int? stripe = 0;
  int? paypal = 0;
  int? razor = 0;
  int? flutterWave = 0;
  int? payStack = 0;

  String? userPhoneNo = "";
  String? userEmail = "";
  String? userName = "";

  // Payment count //
  SingingCharacter? _character;
  int? selectedRadio;
  late var str;
  var parts;
  var paymentType;
  var startPart;

  int _currentStep = 0;
  StepperType stepperType = StepperType.horizontal;

  String? selectTime = "";

  String? name = "";
  String? expertise = "";
  String? appointmentFees = "";
  dynamic newAppointmentFees = 0.0;
  String? experience = "";
  dynamic rate = 0;
  String? desc = "";
  String education = "";
  String certificate = "";
  String? fullImage = "";
  String? treatmentName = "";
  String? hospitalName = "";
  String? hospitalAddress = "";

  List<Hosiptal> hospital = [];
  List<HospitalGallery> hospitalGallery = [];

  TextEditingController patientNameController = TextEditingController();
  TextEditingController illnessInformation = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController patientAddressController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController note = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();

  TextEditingController _offerController = TextEditingController();

  String reportImage = "";
  String reportImage1 = "";
  String reportImage2 = "";
  File? _proImage;
  File? _proImage1;
  File? _proImage2;
  final picker = ImagePicker();

  List<Datas> timeList = [];

  DateTime? _selectedDate;
  late DateTime _firstTimeSelected;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2 = GlobalKey<FormState>();

  final GlobalKey<FormState> _offerFormKey = GlobalKey<FormState>();

  List<String> appointmentFor = [];
  String? selectAppointmentFor;

  List<String> drugEffects = [];
  String? selectDrugEffects;

  int? id = 0;
  String newDate = "";
  String newDateUser = "";

  String passBookDate = "";
  String passBookTime = "";
  String passBookID = "";

  String? bookingId = "";

  //Discount //
  String discountType = "";
  int? isFlat = 0;
  int? flatDiscount = 0;
  int? discount = 0;
  int? minDiscount = 0;
  DateTime? todayDate;
  double prAmount = 0;

  _getDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        userPhoneNo = prefs.getString('phone_no');
        userEmail = prefs.getString('email');
        userName = prefs.getString('name');
      },
    );
  }

  _passDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        passBookDate = '$newDateUser';
        passBookTime = '$selectTime';
        passBookID = '$bookingId';
        prefs.setString('BookDate', passBookDate);
        prefs.setString('BookTime', passBookTime);
        prefs.setString('BookID', passBookID);
      },
    );
  }

  var publicKey =
      MySharedPreferenceHelper.getString(Preferences.payStack_public_key);
  final plugin = PaystackPlugin();
  String? paymentToken = "";

  @override
  void initState() {
    _character = SingingCharacter.COD;
    note.text = "NO";
    illnessInformation.text = "Nono";
    patientAddressController.text = "Nono";
    super.initState();
    id = widget.id;
    callApiDoctorDetail();
    _getDetail();
    selectedRadio = 0;
    callApiSetting();

    Future.delayed(Duration.zero, () {
      appointmentFor = [
        getTranslated(context, bookAppointment_mySelf).toString(),
        getTranslated(context, bookAppointment_patient).toString()
      ];
      drugEffects = [
        getTranslated(context, Yes).toString(),
        getTranslated(context, No).toString()
      ];
    });

    // RazorPay //
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // PayStack //
    plugin.initialize(
        publicKey:
            MySharedPreferenceHelper.getString(Preferences.payStack_public_key)!);
    todayDate = DateTime.now();
    _firstTimeSelected = DateTime.now();
    date
      ..text = DateFormat('dd-MM-yyyy').format(_firstTimeSelected)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: date.text.length, affinity: TextAffinity.upstream),
      );
    var temp = '$_firstTimeSelected';
    // Date Formate  dispaly user
    newDateUser = DateUtil().formattedDate(DateTime.parse(temp));
    // // Date Formate pass Api
    newDate = DateUtilforpass().formattedDate(DateTime.parse(temp));

    date.text = newDateUser;

    setState(() {
      timeSlot();
    });
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  // RazorPay Clear //
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width * 0.3, size.height * 0.25),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
                  color: Palette.transparent,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(
                        right: width * 0.02, left: width * 0.02),
                    child: GestureDetector(
                      child: Icon(Icons.arrow_back_ios),
                      onTap: () {
                        if (_currentStep == 0) Navigator.pop(context);
                        if (_currentStep == 1) cancel();
                        if (_currentStep == 2) cancel();
                      },
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: width * 0.04, right: width * 0.04),
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              width: width * 0.2,
                              height: width * 0.2,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                imageUrl: '$fullImage',
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Palette.image_circle,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    SpinKitPulse(color: Palette.blue),
                                errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.asset(
                                      "assets/images/no_image.jpg",
                                      width: width * 0.2,
                                      height: width * 0.2,
                                      fit: BoxFit.fitHeight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * 0.6,
                        margin: EdgeInsets.only(
                            left: width * 0.04, right: width * 0.04),
                        child: Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Column(
                                children: [
                                  Text(
                                    '$hospitalName',
                                    style: TextStyle(
                                        fontSize: width * 0.047,
                                        color: Palette.dark_blue),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.only(top: width * 0.01),
                              child: Column(
                                children: [
                                  Text(
                                    '$name',
                                    style: TextStyle(
                                        fontSize: width * 0.048,
                                        color: Palette.black),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: width * 0.01),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/location1.svg',
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: width * 0.5,
                                    alignment: AlignmentDirectional.topStart,
                                    margin: EdgeInsets.only(
                                        top: width * 0.01,
                                        left: width * 0.02,
                                        right: width * 0.02),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$hospitalAddress',
                                          style: TextStyle(
                                            fontSize: width * 0.03,
                                            color: Palette.grey,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  // color: Colors.red,

                  margin: EdgeInsets.only(top: width * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          getTranslated(
                                  context, bookAppointment_appointmentFees)
                              .toString(),
                          style: TextStyle(
                              fontSize: width * 0.045, color: Colors.red[900]),
                        ),
                      ),
                      Container(
                        child: Text(
                          MySharedPreferenceHelper.getString(
                                      Preferences.currency_symbol)
                                  .toString() +
                              '$appointmentFees',
                          style: TextStyle(
                              fontSize: width * 0.04, color: Colors.grey[900]),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        body: ModalProgressHUD(
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: Stepper(
                      type: stepperType,
                      physics: ScrollPhysics(),
                      onStepCancel: null,
                      currentStep: _currentStep,
                      onStepTapped: (step) {
                        if (_step1.currentState!.validate()) {
                          tapped(step);
                        }
                      },
                      onStepContinue: continued,
                      steps: <Step>[
                        // Step 1 //
                        Step(
                          title: new Text(
                            getTranslated(context,
                                    bookAppointment_appointmentFor_hint)
                                .toString(),
                          ),
                          content: Form(
                            key: _step1,
                            child: SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                        visible: false,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: width * 0.03),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    getTranslated(context,
                                                            bookAppointment_appointmentFor_title)
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: width * 0.04,
                                                        color: Colors.red[900],
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ),
                                            DropdownButtonFormField(
                                              hint: Text(
                                                getTranslated(context,
                                                            bookAppointment_mySelf)
                                                        .toString() +
                                                    ' / ' +
                                                    getTranslated(context,
                                                            bookAppointment_patient)
                                                        .toString(),
                                                style: TextStyle(
                                                  fontSize: width * 0.035,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              value: getTranslated(context,
                                                      bookAppointment_mySelf)
                                                  .toString(),
                                              isExpanded: true,
                                              iconSize: 30,
                                              onSaved: (dynamic value) {
                                                setState(() {
                                                  selectAppointmentFor = value;
                                                });
                                              },
                                              onChanged: (dynamic newValue) {
                                                setState(
                                                  () {
                                                    selectAppointmentFor =
                                                        newValue;
                                                  },
                                                );
                                              },
                                              validator: (dynamic value) =>
                                                  value == null
                                                      ? getTranslated(context,
                                                              bookAppointment_appointmentFor_validator)
                                                          .toString()
                                                      : null,
                                              items: appointmentFor
                                                  .map((location) {
                                                return DropdownMenuItem<String>(
                                                  child: new Text(
                                                    location,
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Colors.red[900],
                                                    ),
                                                  ),
                                                  value: location,
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        )),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context,
                                                    bookAppointment_patient_title)
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Colors.red[900],
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: patientNameController,
                                      keyboardType: TextInputType.text,
                                      // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Colors.red[900],
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context,
                                                bookAppointment_patient_hint)
                                            .toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      validator: (String? value) {
                                        value!.trim();
                                        if (value.isEmpty) {
                                          return getTranslated(context,
                                                  bookAppointment_patient_validator1)
                                              .toString();
                                        } else if (value.trim().length < 1) {
                                          return getTranslated(context,
                                                  bookAppointment_patient_validator2)
                                              .toString();
                                        }
                                        return null;
                                      },
                                      onChanged: (String name) {
                                        name.trim();
                                      },
                                    ),
                                    if (illnessInformation.text.isEmpty) ...{
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: width * 0.05),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context,
                                                      bookAppointment_illness_title)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_blue,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        textCapitalization:
                                            TextCapitalization.words,
                                        controller: illnessInformation,
                                        keyboardType: TextInputType.text,
                                        // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9 ]'))],
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.dark_blue,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: getTranslated(context,
                                                  bookAppointment_illness_hint)
                                              .toString(),
                                          // 'Enter patient illness',
                                          hintStyle: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context,
                                                    bookAppointment_illness_validator1)
                                                .toString();
                                          } else if (value.trim().length < 1) {
                                            return getTranslated(context,
                                                    bookAppointment_illness_validator2)
                                                .toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                    },
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context,
                                                    bookAppointment_age_title)
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.dark_blue,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      controller: age,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[a-zA-Z0-9]'))
                                      ],
                                      style: TextStyle(
                                        fontSize: width * 0.04,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context,
                                                bookAppointment_age_hint)
                                            .toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context,
                                                  bookAppointment_age_validator)
                                              .toString();
                                        }
                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                    if (patientAddressController
                                        .text.isEmpty) ...{
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: width * 0.05),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context,
                                                      bookAppointment_patientAddress_title)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_blue,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: patientAddressController,
                                        keyboardType: TextInputType.text,
                                        // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9, ]'))],
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.dark_blue,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: getTranslated(context,
                                                  bookAppointment_patientAddress_text)
                                              .toString(),
                                          hintStyle: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context,
                                                    bookAppointment_patientAddress_validator1)
                                                .toString();
                                          } else if (value.trim().length < 1) {
                                            return getTranslated(context,
                                                    bookAppointment_patientAddress_validator2)
                                                .toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                    },
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: width * 0.05),
                                      child: Column(
                                        children: [
                                          Text(
                                            getTranslated(context,
                                                    bookAppointment_phoneNo_title)
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.dark_blue,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    TextFormField(
                                      controller: phoneNoController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9]')),
                                        LengthLimitingTextInputFormatter(11)
                                      ],
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context,
                                                bookAppointment_phoneNo_hint)
                                            .toString(),
                                        hintStyle: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      // validator: (String? value) {
                                      //   String patttern =
                                      //       r'(01)(0|1|2|5)[0-9]{8}';
                                      //   RegExp regExp = new RegExp(patttern);
                                      //   if (value!.length == 0 ||
                                      //       value.length > 11) {
                                      //     return getTranslated(context,
                                      //             bookAppointment_phoneNo_Validator1)
                                      //         .toString();
                                      //   } else if (!regExp.hasMatch(value)) {
                                      //     return getTranslated(context,
                                      //             bookAppointment_phoneNo_Validator2)
                                      //         .toString();
                                      //   }
                                      //   return null;
                                      // },
                                      onSaved: (String? name) {},
                                    ),
                                    /*
                                     Visibility(
                                        visible: false,
                                        child:
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: width * 0.05),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    getTranslated(context, bookAppointment_sideEffects_title).toString(),
                                                    style:
                                                    TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ),
                                            DropdownButtonFormField(
                                              hint: Text(
                                                getTranslated(context, bookAppointment_sideEffects_hint).toString(),
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              value: "No",//selectDrugEffects,
                                              isExpanded: true,
                                              iconSize: 30,
                                              onSaved: (dynamic value) {
                                                setState(() {
                                                  selectDrugEffects = value;
                                                });
                                              },
                                              onChanged: (dynamic newValue) {
                                                setState(
                                                      () {
                                                    selectDrugEffects = newValue;
                                                  },
                                                );
                                              },
                                              validator: (dynamic value) =>
                                              value == null ? getTranslated(context, bookAppointment_sideEffects_validator).toString() : null,
                                              items: drugEffects.map((location) {
                                                return DropdownMenuItem<String>(
                                                  child: new Text(
                                                    location,
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  ),
                                                  value: location,
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        )

                                    ),
                                     */

                                    if (note.text.isEmpty) ...{
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: width * 0.05),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context,
                                                      bookAppointment_note_title)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: width * 0.038,
                                                  color: Palette.dark_blue,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: note,
                                        keyboardType: TextInputType.text,
                                        // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9,. ]'))],
                                        maxLength: 40,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          color: Palette.dark_blue,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: getTranslated(context,
                                                  bookAppointment_note_hint)
                                              .toString(),
                                          hintStyle: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context,
                                                    bookAppointment_note_validator1)
                                                .toString();
                                          } else if (value.trim().length < 1) {
                                            return getTranslated(context,
                                                    bookAppointment_note_validator2)
                                                .toString();
                                          }
                                          return null;
                                        },
                                        onSaved: (String? name) {},
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: width * 0.05),
                                        child: Column(
                                          children: [
                                            Text(
                                              getTranslated(context,
                                                      bookAppointment_reportImage_title)
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_blue),
                                            )
                                          ],
                                        ),
                                      ),
                                    },
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.only(
                                                    top: width * 0.028,
                                                    left: width * 0.02,
                                                    right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    child: _proImage != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage();
                                                            },
                                                            child: Image.file(
                                                              _proImage!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height:
                                                                width * 0.24,
                                                            width: width * 0.24,
                                                            child:
                                                                CachedNetworkImage(
                                                              height:
                                                                  width * 0.24,
                                                              width:
                                                                  width * 0.24,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              imageUrl:
                                                                  reportImage,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitFadingCircle(
                                                                      color: Palette
                                                                          .blue),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .add_outlined,
                                                                  size: 50,
                                                                  color: Palette
                                                                      .blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: width * 0.028,
                                                    left: width * 0.02,
                                                    right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    child: _proImage1 != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage1();
                                                            },
                                                            child: Image.file(
                                                              _proImage1!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height:
                                                                width * 0.24,
                                                            width: width * 0.24,
                                                            child:
                                                                CachedNetworkImage(
                                                              height:
                                                                  width * 0.24,
                                                              width:
                                                                  width * 0.24,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              imageUrl:
                                                                  reportImage1,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitFadingCircle(
                                                                      color: Palette
                                                                          .blue),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .add_outlined,
                                                                  size: 50,
                                                                  color: Palette
                                                                      .blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage1();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                margin: EdgeInsets.only(
                                                    top: width * 0.028,
                                                    left: width * 0.02,
                                                    right: width * 0.02),
                                                child: Container(
                                                  height: width * 0.24,
                                                  width: width * 0.24,
                                                  child: Card(
                                                    color: Palette.dash_line,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    child: _proImage2 != null
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              _chooseProfileImage2();
                                                            },
                                                            child: Image.file(
                                                              _proImage2!,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          )
                                                        : Container(
                                                            height:
                                                                width * 0.24,
                                                            width: width * 0.24,
                                                            child:
                                                                CachedNetworkImage(
                                                              height:
                                                                  width * 0.24,
                                                              width:
                                                                  width * 0.24,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              imageUrl:
                                                                  reportImage2,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitFadingCircle(
                                                                      color: Palette
                                                                          .blue),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .add_outlined,
                                                                  size: 50,
                                                                  color: Palette
                                                                      .blue,
                                                                ),
                                                                onPressed: () {
                                                                  _chooseProfileImage2();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 0
                              ? StepState.complete
                              : StepState.disabled,
                        ),

                        // Step 2 //
                        Step(
                          title: new Text(
                            getTranslated(context, bookAppointment_dateTime)
                                .toString(),
                          ),
                          content: Form(
                            key: _step2,
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.only(top: width * 0.01),
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context,
                                                  bookAppointment_appointmentDate_title)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04,
                                              color: Palette.dark_blue),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: width * 0.1,
                                    width: width * 1,
                                    margin: EdgeInsets.only(top: width * 0.02),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Palette.dash_line,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: TextFormField(
                                        focusNode: AlwaysDisabledFocusNode(),
                                        controller: date,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: getTranslated(context,
                                                  bookAppointment_appointmentDate_hint)
                                              .toString(),
                                          hintStyle: TextStyle(
                                              fontSize: width * 0.038,
                                              color: Palette.dark_blue),
                                        ),
                                        onTap: () {
                                          _selectDate(context);
                                        },
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context,
                                                    bookAppointment_appointmentDate_validator)
                                                .toString();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: 0 < timeList.length
                                        ? Column(
                                            children: [
                                              Container(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                margin: EdgeInsets.only(
                                                    top: width * 0.05),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      getTranslated(context,
                                                              bookAppointment_appointmentTime_title)
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              width * 0.04,
                                                          color: Palette
                                                              .dark_blue),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: width * 0.04),
                                                child: GridView.builder(
                                                  itemCount: timeList.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 5,
                                                    mainAxisSpacing: 5,
                                                    crossAxisCount: 3,
                                                    childAspectRatio: 2.2,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              selectTime =
                                                                  timeList[
                                                                          index]
                                                                      .startTime;
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width: width * 0.3,
                                                            child: Card(
                                                              color: selectTime ==
                                                                      timeList[
                                                                              index]
                                                                          .startTime
                                                                  ? Palette.blue
                                                                  : Palette
                                                                      .dash_line,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    child: Text(
                                                                      timeList[
                                                                              index]
                                                                          .startTime!,
                                                                      style: TextStyle(
                                                                          color: selectTime == timeList[index].startTime
                                                                              ? Palette.white
                                                                              : Palette.blue),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            height: height * 0.4,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                getTranslated(
                                                        context, clinic_closed)
                                                    .toString(),
                                                // getTranslated(context,
                                                //         bookAppointment_selectOtherDate)
                                                //     .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color: Palette.grey),
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 1
                              ? StepState.complete
                              : StepState.disabled,
                        ),

                        // Step 3 //
                        Step(
                          title: new Text(
                            getTranslated(
                                    context, bookAppointment_payment_title)
                                .toString(),
                          ),
                          content: GestureDetector(
                            onTap: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            child: Container(
                              height: height / 1.5,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                shrinkWrap: false,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Form(
                                    key: _offerFormKey,
                                    child: Container(
                                      height: height * 0.1,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * 0.5,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: width * 0.03),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Palette.dark_white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: TextFormField(
                                              controller: _offerController,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: getTranslated(context,
                                                        bookAppointment_offerCode_hint)
                                                    .toString(),
                                                hintStyle: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Palette.dark_grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              validator: (String? value) {
                                                if (value!.isEmpty) {
                                                  return getTranslated(context,
                                                          bookAppointment_offerCode_validator)
                                                      .toString();
                                                }
                                                return null;
                                              },
                                              onSaved: (String? name) {},
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.3,
                                            height: height * 0.05,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: width * 0.03),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 2),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (_offerFormKey.currentState!
                                                    .validate()) {
                                                  callApiApplyOffer();
                                                }
                                              },
                                              child: Text(
                                                getTranslated(context,
                                                        bookAppointment_apply_button)
                                                    .toString(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      paypal == 1
                                          ? Container(
                                              margin: EdgeInsets.all(5),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/PayPal_Logo_Icon_2014.svg/1200px-PayPal_Logo_Icon_2014.svg.png",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Text(
                                                        'PayPal',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Palette.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.Paypal,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                      razor == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://avatars.githubusercontent.com/u/7713209?s=280&v=4",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Text('RazorPay',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Palette
                                                                  .black)),
                                                    ],
                                                  ),
                                                ),
                                                value:
                                                    SingingCharacter.Razorpay,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(
                                                    () {
                                                      _character = value;
                                                      isPaymentClicked = true;
                                                    },
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(),
                                      stripe == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3PGzfbaZZzR0j8rOWBjWJPGWnkPzkm12f5A&usqp=CAU",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Text('Stripe',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Palette
                                                                  .black)),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter.Stripe,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ))
                                          : Container(),
                                      flutterWave == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  // color: Colors.red,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://cdn.filestackcontent.com/OITnhSPCSzOuiVvwnH7r",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                            'Flutterwave',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Palette
                                                                    .black)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                value: SingingCharacter
                                                    .FlutterWave,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ))
                                          : Container(),
                                      payStack == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5,
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "https://website-v3-assets.s3.amazonaws.com/assets/img/hero/Paystack-mark-white-twitter.png",
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                      Text('Paystack',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Palette
                                                                  .black)),
                                                    ],
                                                  ),
                                                ),
                                                value:
                                                    SingingCharacter.PayStack,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(() {
                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                      cod == 1
                                          ? Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Palette.dark_grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Palette.white),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              child: RadioListTile<
                                                  SingingCharacter>(
                                                controlAffinity:
                                                    ListTileControlAffinity
                                                        .trailing,
                                                title: Text(
                                                  'ادفع في العياده',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Palette.black),
                                                ),
                                                value: SingingCharacter.COD,
                                                activeColor: Palette.black,
                                                groupValue: _character,
                                                onChanged:
                                                    (SingingCharacter? value) {
                                                  setState(() {
                                                    print("dd = " +
                                                        value.toString());

                                                    _character = value;
                                                    isPaymentClicked = true;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep >= 2
                              ? StepState.complete
                              : StepState.disabled,
                        ),
                      ],

                      /*

                      controlsBuilder: (BuildContext context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) async {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(),
                            SizedBox(),
                          ],
                        );
                      },
                       */
                    ),
                  ),
                ],
              ),
            ),
          ),
          inAsyncCall: loading,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
        ),
        bottomNavigationBar: Container(
          height: 50,
          child: ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentStep == 0)
                  Text(
                    getTranslated(context, bookAppointment_continue_button)
                        .toString(),
                    style:
                        TextStyle(fontSize: width * 0.04, color: Palette.white),
                  ),
                if (_currentStep == 1)
                  Text(
                    getTranslated(context, bookAppointment_continue_button)
                        .toString(),
                    style:
                        TextStyle(fontSize: width * 0.04, color: Palette.white),
                  ),
                if (_currentStep == 2)
                  '$newAppointmentFees' == "0.0"
                      ? Text(
                          getTranslated(context, bookAppointment_pay_button)
                                  .toString() +
                              MySharedPreferenceHelper.getString(
                                      Preferences.currency_symbol)
                                  .toString() +
                              '$appointmentFees',
                          style: TextStyle(
                              fontSize: width * 0.04, color: Palette.white),
                        )
                      : Text(
                          getTranslated(context, bookAppointment_pay_button)
                                  .toString() +
                              MySharedPreferenceHelper.getString(
                                      Preferences.currency_symbol)
                                  .toString() +
                              '$newAppointmentFees',
                          style: TextStyle(
                              fontSize: width * 0.04, color: Palette.white),
                        )
              ],
            ),
            onPressed: () {
              setState(
                () {
                  if (_currentStep == 0 && _step1.currentState!.validate()) {
                    continued();
                  } else if (_currentStep == 1 &&
                      selectTime != null &&
                      selectTime != "" &&
                      selectTime != "null") {
                    continued();
                  } else if (_currentStep == 2) {
                    str = "$_character";
                    parts = str.split(".");
                    startPart = parts[0].trim();
                    paymentType = parts.sublist(1).join('.').trim();

                    if (_character!.index == 0) {
                      print('Paypal');
                    } else if (_character!.index == 1) {
                      openCheckoutRazorPay();
                      print('Razorpay');
                    } else if (_character!.index == 2) {
                      print('Stripe');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StripePaymentScreen(
                            selectAppointmentFor: selectAppointmentFor,
                            patientName: patientNameController.text,
                            illnessInformation: illnessInformation.text,
                            age: age.text,
                            patientAddress: patientAddressController.text,
                            phoneNo: phoneNoController.text,
                            selectDrugEffects: selectDrugEffects,
                            note: note.text,
                            newDate: newDate,
                            selectTime: selectTime,
                            appointmentFees: "$newAppointmentFees" != "0.0"
                                ? '$newAppointmentFees'
                                : '$appointmentFees',
                            doctorId: id,
                            newDateUser: newDateUser,
                            reportImages: reportImages,
                          ),
                        ),
                      );
                    } else if (_character!.index == 3) {
                      beginPayment();
                      print('FlutterWave');
                    } else if (_character!.index == 4) {
                      print('PayStack');
                      payStackFunction();
                    } else if (_character!.index == 5) {
                      print('cod');
                      setState(() {
                        callApiBook();
                      });
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Bookappointments>> callApiBook() async {
    Bookappointments response;
    Map<String, dynamic> body = {
      "appointment_for": getTranslated(context, bookAppointment_mySelf)
          .toString(), // selectAppointmentFor,
      "patient_name": patientNameController.text,
      "illness_information": illnessInformation.text,
      "age": age.text,
      "patient_address": patientAddressController.text,
      "phone_no": phoneNoController.text,
      "drug_effect": "None", //selectDrugEffects,
      "note": note.text,
      "date": newDate,
      "time": selectTime,
      "payment_type": paymentType,
      "payment_status": _character!.index == 5 ? 0 : 1,
      "_paymentToken": _character!.index == 5 ? "" : _paymentToken,
      "amount": newAppointmentFees != 0.0
          ? newAppointmentFees.toString()
          : appointmentFees,
      "doctor_id": id,
      "report_image": reportImages.length != 0 ? reportImages : "",
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi().dioData()).bookAppointment(body);
      if (response.success == true) {
        // Navigator.pushNamed(context, "Appointment");
        setState(() {
          Preferences.hideDialog(context);
          bookingId = response.data;
          _passDateTime();
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          Navigator.pushReplacementNamed(context, 'BookSuccess');
        });
      } else {
        Preferences.hideDialog(context);
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // RazorPay Code //
  void openCheckoutRazorPay() async {
    var map = {
      'key': MySharedPreferenceHelper.getString(Preferences.razor_key),
      'amount': "$newAppointmentFees" != "0.0"
          ? num.parse('$newAppointmentFees') * 100
          : num.parse('$appointmentFees') * 100,
      'name': '$businessName',
      'currency': MySharedPreferenceHelper.getString(Preferences.currency_code),
      'image': '$logo',
      'description': '',
      'send_sms_hash': 'true',
      'prefill': {'contact': '$userPhoneNo', 'email': '$userEmail'},
      'external': {
        'wallets': ['paytm']
      }
    };
    var options = map;

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  // RazorPay Success Method //
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId, toastLength: Toast.LENGTH_SHORT);
    // Fluttertoast.showToast(msg: "SUCCESS: ", toastLength: Toast.LENGTH_SHORT);
    _paymentToken = response.paymentId;
    _paymentToken != "" && _paymentToken!.isNotEmpty
        ? callApiBook()
        : Fluttertoast.showToast(
            msg:
                getTranslated(context, bookAppointment_paymentNotComplete_toast)
                    .toString(),
            toastLength: Toast.LENGTH_SHORT);
  }

  // RazorPay Error Method //
  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message,
    //     toastLength: Toast.LENGTH_SHORT);
  }

  // RazorPay Wallet Method //
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName, toastLength: Toast.LENGTH_SHORT);
  }

  // FlutterWave Code //
  beginPayment() async {
    final Flutterwave flutterwave = Flutterwave.forUIPayment(
      context: this.context,
      encryptionKey: MySharedPreferenceHelper.getString(
          Preferences.flutterWave_encryption_key)!,
      publicKey: MySharedPreferenceHelper.getString(Preferences.flutterWave_key)!,
      currency: MySharedPreferenceHelper.getString(Preferences.currency_code)!,
      // this.currency,
      amount: "$newAppointmentFees" != "0.0"
          ? '$newAppointmentFees'
          : '$appointmentFees',
      email: "$userEmail",
      fullName: "$userName",
      txRef: DateTime.now().toIso8601String(),
      isDebugMode: true,
      phoneNumber: "$userPhoneNo",
      acceptCardPayment: true,
      acceptUSSDPayment: false,
      acceptAccountPayment: false,
      acceptFrancophoneMobileMoney: false,
      acceptGhanaPayment: false,
      acceptMpesaPayment: false,
      acceptRwandaMoneyPayment: false,
      acceptUgandaPayment: false,
      acceptZambiaPayment: false,
    );

    try {
      final ChargeResponse? response =
          await flutterwave.initializeForUiPayments();
      if (response == null) {
        // user didn't complete the transaction. Payment wasn't successful.
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response);
        if (isSuccessful) {
          // provide value to customer
        } else {
          // check message
          print("response message ${response.message}");
        }
      }
    } catch (error, stacktrace) {
      // handleError(error);
      print("error is $stacktrace");
    }
  }

  bool checkPaymentIsSuccessful(final ChargeResponse response) {
    _paymentToken = response.data!.flwRef;
    _paymentToken != "" && _paymentToken!.isNotEmpty
        ? callApiBook()
        : Fluttertoast.showToast(
            msg:
                getTranslated(context, bookAppointment_paymentNotComplete_toast)
                    .toString(),
            toastLength: Toast.LENGTH_SHORT);
    return response.data!.status == FlutterwaveConstants.SUCCESSFUL &&
        response.data!.currency == this.currency &&
        response.data!.amount == this.amount &&
        response.data!.txRef == this.txRef;
  }

  // PayStack //
  payStackFunction() async {
    var amountToPaystack = "$newAppointmentFees" != "0.0"
        ? num.parse('$newAppointmentFees') * 100
        : num.parse('$appointmentFees') * 100;
    Charge charge = Charge()
      ..amount = amountToPaystack as int
      ..reference = _getReference()
      ..currency = MySharedPreferenceHelper.getString(Preferences.currency_code)
      // "ZAR"
      ..email = '$userEmail';
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      _paymentToken = response.reference;
      _paymentToken != "" && _paymentToken!.isNotEmpty
          ? callApiBook()
          : Fluttertoast.showToast(
              msg: getTranslated(
                      context, bookAppointment_paymentNotComplete_toast)
                  .toString(),
              toastLength: Toast.LENGTH_SHORT);
      setState(() {
        paymentToken = response.reference;
      });
    } else {
      print('error');
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Call Doctor Time Api //

  Future<BaseModel<Timeslot>> timeSlot() async {
    Timeslot response;
    timeList.clear();
    Map<String, dynamic> body = {
      "doctor_id": id,
      "date": newDate,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).timeslot(body);
      if (response.success == true) {
        setState(() {
          loading = false;
          timeList.addAll(response.data!);
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // Call Doctor Detail Api //

  Future<BaseModel<Doctordetails>> callApiDoctorDetail() async {
    Doctordetails response;
    setState(() {
      loading = true;
    });
    try {
      response =
          await RestClient(RetroApi2().dioData2()).doctorDetailRequest(id);
      if (response.success == true) {
        setState(() {
          loading = false;
          name = response.data!.name;
          rate = response.data!.rate;
          experience = response.data!.experience;
          appointmentFees = response.data!.appointmentFees;
          desc = response.data!.desc;
          expertise = response.data!.expertise!.name;
          fullImage = response.data!.fullImage;
          treatmentName = response.data!.treatment!.name;

          hospital.addAll(response.data!.hosiptal!);
          for (int i = 0; i < hospital.length; i++) {
            hospitalName = response.data!.hosiptal![i].name;
            hospitalAddress = response.data!.hosiptal![i].address;
          }
          hospitalGallery.addAll(response.data!.hosiptal![0].hospitalGallery!);
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;

    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      if (response.success == true) {
        razorpayKey = response.data!.razorKey;
        businessName = response.data!.businessName;
        logo = response.data!.logo;
        cod = int.parse(response.data!.cod.toString());
        stripe = int.parse(response.data!.stripe.toString());
        paypal = int.parse(response.data!.paypal.toString());
        flutterWave = int.parse(response.data!.flutterwave.toString());
        razor = int.parse(response.data!.razor.toString());
        payStack = int.parse(response.data!.paystack.toString());
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    if (_step1.currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      }
    }
  }

  cancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  // Select Date Method //
  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 366)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Palette.blue,
              onPrimary: Palette.white,
              surface: Palette.blue,
              onSurface: Palette.black,
            ),
            dialogBackgroundColor: Palette.white,
          ),
          child: child!,
        );
      },
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      date
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(
              offset: date.text.length, affinity: TextAffinity.upstream),
        );
      var temp = '$_selectedDate';
      // Date Formate  dispaly user
      newDateUser = DateUtil().formattedDate(DateTime.parse(temp));
      // Date Formate pass Api
      newDate = DateUtilforpass().formattedDate(DateTime.parse(temp));
    }
    timeSlot();
  }

  // Select Image //
  void _proImgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          MySharedPreferenceHelper.setString(
              Preferences.reportImage, pickedFile.path);
          _proImage =
              File(MySharedPreferenceHelper.getString(Preferences.reportImage)!);
          List<int> imageBytes = _proImage!.readAsBytesSync();
          reportImage = base64Encode(imageBytes);
          if (reportImage != "null") {
            reportImages.add(reportImage);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        MySharedPreferenceHelper.setString(
            Preferences.reportImage, pickedFile.path);
        _proImage =
            File(MySharedPreferenceHelper.getString(Preferences.reportImage)!);
        List<int> imageBytes = _proImage!.readAsBytesSync();
        reportImage = base64Encode(imageBytes);
        if (reportImage != "null") {
          reportImages.add(reportImage);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  // Select Image1 //
  void _proImgFromGallery1() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          MySharedPreferenceHelper.setString(
              Preferences.reportImage1, pickedFile.path);
          _proImage1 =
              File(MySharedPreferenceHelper.getString(Preferences.reportImage1)!);
          List<int> imageBytes = _proImage1!.readAsBytesSync();
          reportImage1 = base64Encode(imageBytes);
          if (reportImage1 != "null") {
            reportImages.add(reportImage1);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera1() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        MySharedPreferenceHelper.setString(
            Preferences.reportImage1, pickedFile.path);
        _proImage1 =
            File(MySharedPreferenceHelper.getString(Preferences.reportImage1)!);
        List<int> imageBytes = _proImage1!.readAsBytesSync();
        reportImage1 = base64Encode(imageBytes);
        if (reportImage1 != "null") {
          reportImages.add(reportImage1);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  // Select Image2 //
  void _proImgFromGallery2() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          MySharedPreferenceHelper.setString(
              Preferences.reportImage2, pickedFile.path);
          _proImage2 =
              File(MySharedPreferenceHelper.getString(Preferences.reportImage2)!);
          List<int> imageBytes = _proImage2!.readAsBytesSync();
          reportImage2 = base64Encode(imageBytes);
          if (reportImage2 != "null") {
            reportImages.add(reportImage2);
          }
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera2() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        MySharedPreferenceHelper.setString(
            Preferences.reportImage2, pickedFile.path);
        _proImage2 =
            File(MySharedPreferenceHelper.getString(Preferences.reportImage2)!);
        List<int> imageBytes = _proImage2!.readAsBytesSync();
        reportImage2 = base64Encode(imageBytes);
        if (reportImage2 != "null") {
          reportImages.add(reportImage2);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  //  Offer //

  Future<BaseModel<ApplyOffer>> callApiApplyOffer() async {
    ApplyOffer response;
    var offerDateToday = "$todayDate";
    String offerDate =
        DateUtilforpass().formattedDate(DateTime.parse(offerDateToday));
    Map<String, dynamic> body = {
      "offer_code": _offerController.text,
      "date": offerDate,
      "doctor_id": id,
      "from": "appointment",
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).applyOfferRequest(body);
      if (response.success == true) {
        setState(() {
          loading = false;
          discountType = response.data!.discountType!.toUpperCase();
          flatDiscount = response.data!.flatDiscount;
          isFlat = response.data!.isFlat;
          minDiscount = response.data!.minDiscount;
          discount = response.data!.discount;

          if (discountType == "AMOUNT" && isFlat == 1) {
            if (int.parse('$appointmentFees') > flatDiscount!) {
              if (flatDiscount! < minDiscount!) {
                newAppointmentFees =
                    int.parse('$appointmentFees') - int.parse('$flatDiscount');
              } else {
                newAppointmentFees =
                    int.parse('$appointmentFees') - int.parse('$minDiscount');
              }
              Fluttertoast.showToast(
                msg: getTranslated(context, bookAppointment_offerApply_toast)
                    .toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            } else {
              Fluttertoast.showToast(
                msg: getTranslated(context, bookAppointment_worthMore_toast)
                        .toString() +
                    MySharedPreferenceHelper.getString(
                            Preferences.currency_symbol)
                        .toString() +
                    '$flatDiscount.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          } else if (discountType == "AMOUNT" && isFlat == 0) {
            if (int.parse('$appointmentFees') > discount!) {
              if (discount! < minDiscount!) {
                newAppointmentFees =
                    int.parse('$appointmentFees') - int.parse('$discount');
              } else {
                newAppointmentFees =
                    int.parse('$appointmentFees') - int.parse('$minDiscount');
              }
              Fluttertoast.showToast(
                msg: getTranslated(context, bookAppointment_offerApply_toast)
                    .toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            } else {
              Fluttertoast.showToast(
                msg: getTranslated(context, bookAppointment_worthMore_toast)
                        .toString() +
                    MySharedPreferenceHelper.getString(
                            Preferences.currency_symbol)
                        .toString() +
                    '$discount.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
            }
          } else if (discountType == "PERCENTAGE") {
            setState(() {
              prAmount =
                  (int.parse('$appointmentFees') * int.parse('$discount')) /
                      100;
              if (prAmount <= minDiscount!) {
                newAppointmentFees = double.parse('$appointmentFees') -
                    double.parse('$prAmount');
              } else {
                newAppointmentFees = double.parse('$appointmentFees') -
                    double.parse('$minDiscount');
              }
            });
            Fluttertoast.showToast(
              msg: int.parse('$appointmentFees') >= prAmount ||
                      int.parse('$appointmentFees') >= minDiscount!
                  ? getTranslated(context, bookAppointment_offerApply_toast)
                      .toString()
                  : getTranslated(context, bookAppointment_itemWorth_toast)
                          .toString() +
                      '$prAmount' +
                      getTranslated(context, bookAppointment_orMore_toast)
                          .toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
            newAppointmentFees = int.parse('$appointmentFees') >= prAmount ||
                    int.parse('$appointmentFees') >= minDiscount!
                ? newAppointmentFees
                : appointmentFees;
          }
        });
      } else {
        setState(() {
          loading = false;
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // Image Function //
  void _chooseProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      getTranslated(context, fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _chooseProfileImage1() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      getTranslated(context, fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery1();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera1();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _chooseProfileImage2() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      getTranslated(context, fromGallery).toString(),
                    ),
                    onTap: () {
                      _proImgFromGallery2();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    getTranslated(context, fromCamera).toString(),
                  ),
                  onTap: () {
                    _proImgFromCamera2();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Date Format  Dispaly user
class DateUtil {
  static const DATE_FORMAT = 'dd-MM-yyyy';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

// Date Format pass Api
class DateUtilforpass {
  static const DATE_FORMAT = 'yyyy-MM-dd';

  String formattedDate(DateTime dateTime) {
    return DateFormat(DATE_FORMAT).format(dateTime);
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
