import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collect/View/InputField.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart' hide ServiceStatus;
import 'package:collect/Controller/collectionController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:location/location.dart' hide LocationAccuracy;

class Home extends StatefulWidget {
  final LatLng? currentPosition;
  const Home({Key? key, this.currentPosition}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isActivated = false, isValidate = false, loading = false;
  File? image;
  final picker = ImagePicker();

  final Completer<GoogleMapController> _controller = Completer();
  //LatLng? currentPosition;
  final Location _location = Location();
  final spaceController = Get.put(CollectionController());

  final sub = TextEditingController();
  final ward = TextEditingController();
  final cost = TextEditingController();
  final projects = TextEditingController();
  final name = TextEditingController();
  final employees = TextEditingController();
  final resources = TextEditingController();
  final rating = TextEditingController();
  final challenges = TextEditingController();
  double? latitude, longitude;
  String? url;
  // Set<Marker> _markers = Set();
  final controller = Get.put(CollectionController());

  List<String> category = [
    "Administration, ICT & Public Service",
    "Agriculture, Livestock & Co-operatives",
    "Water, Sanitation & Environment",
    "Medical Services & Public Health",
    "Education & Vocational Training",
    "Lands, Housing & Urban Planning",
    "Roads, Public Works & Transport",
    "Trade, Industry & Tourism",
    "Youth, Gender, Sports & Culture",
    "Bomet Municipality"
  ];

  List<String> progress = [
    "Starting",
    "Ongoing",
    "Almost Complete",
    "Complete"
  ];
  final List<Marker> _markers = [
    const Marker(
        markerId: MarkerId('marker_2'),
        position: LatLng(36.959988288487104, -0.398163985596978),
        draggable: true),
  ];

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              children: [
                Center(child: showTitle("Project Progress")),
                InputField(
                    title: "Name",
                    hint: "Enter the project name",
                    controller: name),
                InputField(
                    title: "Sub-County",
                    hint: "Enter the sub-county",
                    controller: sub),
                InputField(
                    title: "Ward", hint: "Enter the ward", controller: ward),
                rowDates(),
                rowCost(),
                InputField(
                  title: "Are  there Complement Projects?",
                  hint: "Complement projects",
                  controller: projects,
                  inputType: TextInputType.text,
                ),
                InputField(
                  title: "Are  there enough resources?",
                  hint: "Are the resources enough?",
                  controller: resources,
                  inputType: TextInputType.multiline,
                ),
                dropDownProgress(),
                displayImage(),
                dropDownCategory(),
                InputField(
                  title: "Note the Challenges?",
                  hint: "Challenges",
                  controller: challenges,
                  inputType: TextInputType.multiline,
                ),
                InputField(
                  title: "How can you Rate the Project?",
                  hint: "Write your ratings here",
                  controller: rating,
                  inputType: TextInputType.number,
                ),
                mapContain(),
                rowButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget rowCounty() {
    return Row(
      children: [
        Expanded(
          child: InputField(
              title: "Sub-County",
              hint: "Enter the sub-county",
              controller: sub),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InputField(
              title: "Ward", hint: "Enter the ward", controller: ward),
        ),
      ],
    );
  }

  Widget rowCost() {
    return Row(
      children: [
        Expanded(
          child: InputField(
            title: "Cost",
            hint: "Project Cost",
            controller: cost,
            inputType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InputField(
            title: "Employees",
            hint: "Employees present",
            controller: employees,
            inputType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget rowDates() {
    return Row(
      children: [datePickStart(), const SizedBox(width: 10), datePickEnd()],
    );
  }

//start date picker
  Widget datePickStart() {
    return GetX<CollectionController>(
      builder: (controller) {
        return Expanded(
          child: InputField(
            title: "Start Date",
            hint: controller.startDate.value,
            widget: IconButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                ).then((date) {
                  setState(() {
                    controller.startDate.value =
                        DateFormat.yMMMd().format(date!);
                  });
                });
              },
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

//end date picker
  Widget datePickEnd() {
    return GetX<CollectionController>(
      builder: (controller) {
        return Expanded(
          child: InputField(
            title: "Expected End Date",
            hint: controller.endDate.value,
            widget: IconButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025),
                ).then((date) {
                  setState(() {
                    controller.endDate.value = DateFormat.yMMMd().format(date!);
                  });
                });
              },
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget dropDownProgress() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Progress",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: GetX<CollectionController>(
              builder: (controller) {
                return DropdownButton2(
                  underline: Container(
                    height: 0,
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 18,
                  ),
                  buttonPadding: const EdgeInsets.only(left: 10, right: 10),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  scrollbarAlwaysShow: true,
                  dropdownMaxHeight: MediaQuery.of(context).size.height * 0.3,
                  hint: showTexts(controller.progress.value),
                  buttonWidth: double.infinity,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  items: progress
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: showTexts(item),
                          ))
                      .toList(),
                  value: controller.progress.value,
                  onChanged: (value) {
                    setState(() {
                      controller.progress.value = value as String;
                      print(value.toString());
                      isActivated = true;
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget dropDownCategory() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Category",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: GetX<CollectionController>(
              builder: (controller) {
                return DropdownButton2(
                  underline: Container(
                    height: 0,
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 18,
                  ),
                  buttonPadding: const EdgeInsets.only(left: 10, right: 10),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  scrollbarAlwaysShow: true,
                  dropdownMaxHeight: MediaQuery.of(context).size.height * 0.3,
                  hint: showTexts(controller.category.value),
                  buttonWidth: double.infinity,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  items: category
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: showTexts(item),
                          ))
                      .toList(),
                  value: controller.category.value,
                  onChanged: (value) {
                    setState(() {
                      controller.category.value = value as String;
                      print(value.toString());
                      isActivated = true;
                    });
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget mapContain() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Map",
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          showMap()
        ],
      ),
    );
  }

  Widget showMap() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        border:
            Border.all(color: const Color.fromARGB(255, 14, 14, 20), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: googleMaps(),
    );
  }

  Widget displayImage() {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Image",
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 8),
              Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Center(
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            image!,
                            width: size.width,
                            height: size.height * 0.32,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text("Select Image",
                          style: GoogleFonts.roboto(
                              fontSize: 16, color: Colors.black87)),
                ),
                // image: image
              ),
            ],
          ),
        ),
        Positioned(top: 35, right: 5, child: iconImage()),
      ],
    );
  }

  Widget iconImage() {
    return IconButton(
        onPressed: () {
          setState(() {
            imageDialog();
          });
        },
        icon: Icon(Icons.add_a_photo,
            size: 20,
            color: image != null
                ? Colors.white
                : const Color.fromARGB(255, 223, 152, 1)));
  }

  Widget showTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
            fontSize: 24,
            color: const Color.fromARGB(255, 24, 23, 37),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget imageTile(ImageSource source, String text, IconData icon) {
    return ListTile(
      selectedColor: Colors.grey,
      onTap: () {
        setState(() async {
          await getImage(source);
          await uploadFile(image!);
          Get.back();
        });
      },
      leading: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
      title: GestureDetector(
        onTap: () {
          setState(() async {
            await getImage(source);
            await uploadFile(image!);
            Get.back();
          });
        },
        child: Text(text,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  Widget showTexts(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.001),
    );
  }

  Future<String?> imageDialog() async {
    final size = MediaQuery.of(context).size;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => Container(
        width: size.width * 0.4,
        height: size.height * 0.16,
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(255, 14, 14, 20), width: 1),
          //border: Border.all(color: Color.fromARGB(255, 182, 36, 116),width:1 ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(5),
          title: const Text('choose image from: '),
          content: SingleChildScrollView(
            child: ListBody(children: [
              imageTile(ImageSource.camera, 'Camera', Icons.camera_alt),
              imageTile(ImageSource.gallery, "Gallery", Icons.photo_library),
              ListTile(
                selectedColor: Colors.grey,
                onTap: () {
                  Get.back();
                },
                leading: const Icon(Icons.cancel, color: Colors.black87),
                title: Text("Cancel",
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource source) async {
    final image = await picker.pickImage(
        source: source, maxHeight: 480, maxWidth: 640, imageQuality: 60);
    try {
      if (image == null) return;

      final imageTempo = File(image.path);
      setState(() {
        this.image = imageTempo;
      });
    } on PlatformException catch (e) {
      showToast(
        "Failed to pick image $e",
      );
    }
  }

  Future<void> showToast(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget googleMaps() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GoogleMap(
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onCameraMove: ((position) => updateCameraPosition(position)),
            markers: Set<Marker>.of(_markers),
            mapType: MapType.hybrid,
            myLocationButtonEnabled: true,
            myLocationEnabled: false,
            tiltGesturesEnabled: true,
            zoomControlsEnabled: false,
            indoorViewEnabled: true,
            zoomGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              target: widget.currentPosition!,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              //getLocation();
              // getPermission();
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: SizedBox(
            height: 30,
            width: 30,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Theme.of(context).cardColor,
              onPressed: () => goToLocation(),
              child: Icon(Icons.my_location,
                  size: 18, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget whiteText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: TextAlign.left,
            style: GoogleFonts.quicksand(
                fontSize: 18,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> goToLocation() async {
    final GoogleMapController controller = await _controller.future;
    _location.onLocationChanged.listen((locationData) {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude!, longitude!),
            zoom: 14,
          ),
        ),
      );
    });
  }

  Future<void> updateCameraPosition(CameraPosition position) async {
    latitude = position.target.latitude;
    longitude = position.target.longitude;
    print(latitude);
    print(longitude);
    Marker marker =
        _markers.firstWhere((p) => p.markerId == const MarkerId('marker_2'));
    _markers.remove(marker);

    _markers.add(
      Marker(
          markerId: const MarkerId('marker_2'),
          position: LatLng(position.target.latitude, position.target.longitude),
          draggable: true),
    );

    setState(() {});
  }

  Widget showButton(String text, Function() function) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.06,
      width: size.width * 0.36,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(const Color.fromARGB(255, 40, 1, 36)),
          // MaterialStateProperty<Color?>?
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(
                color: Color.fromARGB(255, 14, 14, 20),
                width: 2.0,
              ),
            ),
          ),
        ),
        onPressed: function,
        child: Text(text, style: GoogleFonts.roboto(fontSize: 20)),
      ),
    );
  }

  Widget rowButton() {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          showButton("Close", () => exit(0)),
          SizedBox(width: size.width * 0.08),
          loading
              ? const CircularProgressIndicator()
              : showButton("Submit", () async {
                  if (image == null &&
                      name == null &&
                      sub == null &&
                      rating == null &&
                      latitude == null &&
                      longitude == null) {
                    showToast("Fill all the fields");
                  } else {
                    setState(() {
                      loading = true;
                    });
                    await sendData();
                    loading
                        ? const CircularProgressIndicator(
                            color: Color.fromARGB(255, 240, 144, 1),
                          )
                        : await showToast("Information sent Successfully");
                    setState(() {
                      loading = false;
                    });

                    //selectedMethod = null;
                  }
                }),
        ],
      ),
    );
  }

  // getUserLocation() async {
  //   var position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.best,
  //   );
  //
  //   setState(() {
  //     currentPosition = LatLng(position.latitude, position.longitude);
  //     print(currentPosition);
  //   });
  // }

  Future<void> uploadFile(File image) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String filename = path.basename(image.path);
      Reference ref = storage.ref().child("Progress/$filename");
      await ref.putFile(image);
      url = await ref.getDownloadURL();
      print(url);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendData() async {
    CollectionReference plastic =
        FirebaseFirestore.instance.collection("Progress");

    await plastic.add({
      "name": name.text,
      "sub_county": sub.text,
      "ward": ward.text,
      "cost": cost.text,
      "complement_projects": projects.text,
      "employees": employees.text,
      "resources": resources.text,
      "rating": rating.text,
      "challenges": challenges.text,
      "image": url ?? "no url",
      "x_coordinate": latitude,
      "y_coordinate": longitude,
    }).then((value) {
      Fluttertoast.showToast(
          msg: "Data sent successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((error) {
      Fluttertoast.showToast(
          msg: "Data not sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
