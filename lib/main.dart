import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safexpay/constants/strings.dart';
import 'package:safexpay/safexpay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    MerchantConstants.setDetails(
      mId: '202205240004',
      mKey: 'j1C1iS53CGAIY3PDzJCTsMilKdjp14p7lTIWhc40xTI=',
      aggId: 'Paygate',
      environment: Environment.TEST,
    ); //Environment.PRODUCTION
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Safexpay.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: UserInputPage());
  }
}

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  _UserInputPageState createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage>
    implements SafeXPayPaymentCallback {
  TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SafeXPayPaymentCallbackObservable _safeXPayPaymentCallbackObservable;

  @override
  void initState() {
    super.initState();
    _safeXPayPaymentCallbackObservable = SafeXPayPaymentCallbackObservable();
    _safeXPayPaymentCallbackObservable.register(this);
  }

  @override
  void dispose() {
    _safeXPayPaymentCallbackObservable.unRegister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('DemoPaymentApp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: 'Enter the amount to pay'),
            ),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
              onPressed: () {
                String amount = controller.text.toString().trim();
                if (amount.isEmpty) {
                  Utility.showSnackBarMessage(
                      state: _scaffoldKey.currentState!,
                      message: 'Please enter amount to pay');
                } else {
                  SafeXPayGateway safeXPayGateway = SafeXPayGateway(
                    orderNo: '${Random().nextInt(1000)}',
                    amount: double.parse(controller.text),
                    currency: 'AED',
                    transactionType: 'SALE',
                    channel: 'MOBILE',
                    successUrl:
                        'https://1bd1c7cd06b7.ngrok.io/Performance/public/simApp',
                    failureUrl:
                        'https://1bd1c7cd06b7.ngrok.io/Performance/public/simApp',
                    countryCode: 'UAE',
                  );

                  safeXPayGateway.setUserDetails(
                    name: 'faran',
                    emailId: 'faran@palmgrid.com',
                    mobile: '3244529925',
                  );

                  safeXPayGateway.allowedPaymentMethods(
                    allowCardPayment: true,
                    allowNetBankingPayment: true,
                    allowWalletPayment: true,
                    allowUPIPayment: true,
                  );

                  /*  safeXPayGateway.setUdf(
                      UDF1: '73432653',
                      UDF2: '',
                      UDF3: '5215241',
                      UDF4: '',
                      UDF5: '');*/

                  /* MHSafeXPayGateway safeXPayGateway = MHSafeXPayGateway(
                      orderNo: '${Random().nextInt(1000)}',
                      amount: double.parse(controller.text),
                      currency: 'INR',
                      transactionType: 'SALE',
                      channel: 'MOBILE',
                      successUrl: 'http://localhost/Performance/public/simApp',
                      failureUrl: 'http://localhost/Performance/publi/simApp',
                      countryCode: 'IND',
                      pgDetails: '|DC||',
                      customerDetails: 'Nagendra|nagesh@safexpay.com|7710910181| |Y',
                      cardDetails: '||||',
                      billDetails: '||||',
                      shipDetails: '||||||',
                      itemDetails: '||',
                      upiDetails: '',
                      otherDetails: '||||');*/
                  MaterialPageRoute route =
                      MaterialPageRoute(builder: (context) => safeXPayGateway);
                  Navigator.push(context, route);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                // shape: RoundedRectangleBorder(),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onInitiatePaymentFailure(
      String orderID,
      String transactionID,
      String paymentID,
      String paymentStatus,
      String date,
      String time,
      String paymode,
      String amount,
      String udf1,
      String udf2,
      String udf3,
      String udf4,
      String udf5) {
    if (kDebugMode) {
      print(
          'onInitiatePaymentFailure : $orderID -- $transactionID -- $paymentID -- $paymentStatus -- $date -- $time -- $paymode -- $amount -- $udf1 -- $udf2 -- $udf3 -- $udf4 -- $udf5');
    }

    /*Utility.showSnackBarMessage(
        state: _scaffoldKey.currentState!,
        message:
            '$orderID -- $transactionID -- $paymentID -- $paymentStatus -- $date -- $time -- $paymode-- $amount -- $udf1 -- $udf2 -- $udf3 -- $udf4 -- $udf5');*/
  }

  @override
  void onPaymentCancelled() {
    /* Utility.showSnackBarMessage(
        state: _scaffoldKey.currentState!, message: 'Transaction Cancelled');*/

    if (kDebugMode) {
      print('onPaymentCancelled : Transaction Cancelled');
    }
  }

  @override
  void onPaymentComplete(
      String orderID,
      String transactionID,
      String paymentID,
      String paymentStatus,
      String date,
      String time,
      String paymode,
      String amount,
      String udf1,
      String udf2,
      String udf3,
      String udf4,
      String udf5) {
    if (kDebugMode) {
      print(
          'onPaymentComplete : $orderID -- $transactionID -- $paymentID -- $paymentStatus -- $date -- $time -- $paymode -- $amount -- $udf1 -- $udf2 -- $udf3 -- $udf4 -- $udf5');
    }
    /* Utility.showSnackBarMessage(
        state: _scaffoldKey.currentState!,
        message:
            '$orderID -- $transactionID -- $paymentID -- $paymentStatus -- $date -- $time -- $paymode -- $amount -- $udf1 -- $udf2 -- $udf3 -- $udf4 -- $udf5');*/
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        // AppHeader(),
        Expanded(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            // home: LoginScreen(),
          ),
        ),
      ],
    );
  }
}
