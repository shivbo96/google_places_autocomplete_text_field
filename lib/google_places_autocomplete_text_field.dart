library google_places_autocomplete_text_field;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_autocomplete_text_field/model/place_details.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:rxdart/rxdart.dart';

class GooglePlacesAutoCompleteTextFormField extends StatefulWidget {
  final String? initialValue;
  final FocusNode? focusNode;
  final TextEditingController textEditingController;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final bool enableIMEPersonalizedLearning;
  final bool showBottomSheet;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final String? Function(String?)? validator;

  /// Specific to this package
  final ItemClick? itmClick;
  final GetPlaceDetailswWithLatLng? getPlaceDetailWithLatLng;
  final bool isLatLngRequired;
  final String googleAPIKey;
  final int debounceTime;
  final List<String>? countries;
  final TextStyle? predictionsStyle;
  final OverlayContainer? overlayContainer;
  final String? proxyURL;
  final Decoration? suggestionDecoration;
  final ScrollPhysics? physics;
  final Color? bottomSheetColor;
  final PlaceType? placeType;
  final String? language;

  const GooglePlacesAutoCompleteTextFormField({
    super.key,

    ///// SPECIFIC TO THIS PACKAGE
    required this.textEditingController,
    required this.googleAPIKey,
    this.debounceTime = 600,
    this.itmClick,
    this.isLatLngRequired = true,
    this.countries = const [],
    this.getPlaceDetailWithLatLng,
    this.predictionsStyle,
    this.overlayContainer,
    this.proxyURL,
    this.suggestionDecoration,
    this.physics,
    this.bottomSheetColor,
    this.showBottomSheet = false,
    this.placeType,
    this.language = 'en',

    ////// DEFAULT TEXT FORM INPUTS
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.enableIMEPersonalizedLearning = true,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.validator,
  });

  @override
  State<GooglePlacesAutoCompleteTextFormField> createState() => GooglePlacesAutoCompleteTextFormFieldState();
}

class GooglePlacesAutoCompleteTextFormFieldState extends State<GooglePlacesAutoCompleteTextFormField> {
  final subject = PublishSubject<String>();
  OverlayEntry? _overlayEntry;
  List<Prediction> allPredictions = [];

  final LayerLink _layerLink = LayerLink();
  bool isSearched = false;

  final Dio _dio = Dio();
  late FocusNode _focus;

  bool _bottomSheetVisible = false;
  final ValueNotifier<bool> _isShowBottomSheetNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    subject.stream.distinct().debounceTime(Duration(milliseconds: widget.debounceTime)).listen(textChanged);

    _focus = widget.focusNode ?? FocusNode();

    if (!kIsWeb && !Platform.isMacOS) {
      _focus.addListener(() {
        if (!_focus.hasFocus) {
          removeOverlay();
        }
      });
    }

    super.initState();
  }

  void openBottomSheet() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (!_bottomSheetVisible) {
          _showBottomSheet();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.textEditingController,
        initialValue: widget.initialValue,
        focusNode: _focus,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textDirection: widget.textDirection,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        autofocus: widget.autofocus,
        readOnly: (_bottomSheetVisible || widget.showBottomSheet) ? true : widget.readOnly,
        showCursor: widget.showCursor,
        obscuringCharacter: widget.obscuringCharacter,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        onChanged: (string) {
          if (widget.showBottomSheet) {
            widget.textEditingController.clear();
            removeOverlay();
            return;
          }
          widget.onChanged?.call(string);
          subject.add(string);
        },
        onTap: () {
          if (widget.showBottomSheet) {
            openBottomSheet();
            widget.textEditingController.clear();
            removeOverlay();
            return;
          }
          widget.onTap?.call();
        },
        onTapOutside: widget.onTapOutside,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        selectionControls: widget.selectionControls,
        buildCounter: widget.buildCounter,
        scrollPhysics: widget.scrollPhysics,
        autofillHints: widget.autofillHints,
        autovalidateMode: widget.autovalidateMode,
        scrollController: widget.scrollController,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
        mouseCursor: widget.mouseCursor,
        contextMenuBuilder: widget.contextMenuBuilder,
        validator: widget.validator,
      ),
    );
  }

  Future<void> getLocation(String text) async {
    final prefix = widget.proxyURL ?? "";
    String url =
        "${prefix}https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=${widget.googleAPIKey}&language=${widget.language}";

    if (widget.countries != null) {
      for (int i = 0; i < widget.countries!.length; i++) {
        final country = widget.countries![i];

        if (i == 0) {
          url = "$url&components=country:$country";
        } else {
          url = "$url|country:$country";
        }
      }
    }

    if (widget.placeType != null) {
      url += "&types=${widget.placeType?.apiString}";
    }

    final response = await _dio.get(url);
    final subscriptionResponse = PlacesAutocompleteResponse.fromJson(response.data);

    if (text.isEmpty) {
      allPredictions.clear();
      _overlayEntry!.remove();
      return;
    }

    isSearched = false;
    if (subscriptionResponse.predictions!.isNotEmpty) {
      allPredictions.clear();
      allPredictions.addAll(subscriptionResponse.predictions!);
    }
  }

  double heightAccViewInsets(BuildContext context) {
    double height;
    if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
      height = MediaQuery.of(context).size.height * 0.50;
    } else {
      height = MediaQuery.of(context).size.height * 0.75;
    }
    return height;
  }

  Future<void> textChanged(String text) async => getLocation(text).then(
        (_) {
          if (!_bottomSheetVisible) {
            _overlayEntry = null;
            _overlayEntry = _createOverlayEntry();
            Overlay.of(context).insert(_overlayEntry!);
          } else {
            _isShowBottomSheetNotifier.value = !_isShowBottomSheetNotifier.value;
          }
        },
      );

  OverlayEntry? _createOverlayEntry() {
    if (context.findRenderObject() != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

      return OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: size.height + offset.dy,
          width: size.width,
          child: CompositedTransformFollower(
            showWhenUnlinked: false,
            link: _layerLink,
            offset: Offset(0.0, size.height + 5.0),
            child: widget.overlayContainer?.call(_overlayChild) ??
                Material(
                  elevation: 1.0,
                  child: _overlayChild,
                ),
          ),
        ),
      );
    }
    return null;
  }

  Widget get _overlayChild {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics,
      itemCount: allPredictions.length,
      itemBuilder: (BuildContext context, int index) => InkWell(
        onTap: () {
          if (index < allPredictions.length) {
            widget.itmClick!(allPredictions[index]);
            if (!widget.isLatLngRequired) return;

            getPlaceDetailsFromPlaceId(allPredictions[index]);
            removeOverlay();
          }
        },
        child: Container(
          decoration: widget.suggestionDecoration,
          padding: const EdgeInsets.all(10),
          child: Text(
            allPredictions[index].description!,
            style: widget.predictionsStyle ?? widget.style,
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    _focus = FocusNode();
    setState(() {
      _bottomSheetVisible = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.bottomSheetColor,
      showDragHandle: true,
      constraints: BoxConstraints(maxHeight: heightAccViewInsets(context)),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: widget.textEditingController,
              focusNode: _focus,
              decoration: widget.decoration,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              style: widget.style,
              strutStyle: widget.strutStyle,
              textDirection: widget.textDirection,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              showCursor: widget.showCursor,
              obscuringCharacter: widget.obscuringCharacter,
              obscureText: widget.obscureText,
              autocorrect: widget.autocorrect,
              smartDashesType: widget.smartDashesType,
              smartQuotesType: widget.smartQuotesType,
              enableSuggestions: widget.enableSuggestions,
              maxLengthEnforcement: widget.maxLengthEnforcement,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              expands: widget.expands,
              maxLength: widget.maxLength,
              onChanged: (string) {
                widget.onChanged?.call(string);
                subject.add(string);
              },
              onTap: widget.onTap,
              onTapOutside: widget.onTapOutside,
              onEditingComplete: widget.onEditingComplete,
              // onFieldSubmitted: widget.onFieldSubmitted,
              onFieldSubmitted: (value) {
                _overlayEntry!.remove();
                widget.onFieldSubmitted;
              },
              inputFormatters: widget.inputFormatters,
              enabled: widget.enabled,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor,
              keyboardAppearance: widget.keyboardAppearance,
              scrollPadding: widget.scrollPadding,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              selectionControls: widget.selectionControls,
              buildCounter: widget.buildCounter,
              scrollPhysics: widget.scrollPhysics,
              autofillHints: widget.autofillHints,
              autovalidateMode: widget.autovalidateMode,
              scrollController: widget.scrollController,
              enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
              mouseCursor: widget.mouseCursor,
              contextMenuBuilder: widget.contextMenuBuilder,
              validator: widget.validator,
            ),
          ),
          Expanded(child: _bottomSheetChild),
        ],
      ),
    ).whenComplete(() {
      setState(() {
        _bottomSheetVisible = false;
        _focus = widget.focusNode ?? FocusNode();
      });
    });
  }

  Widget get _bottomSheetChild {
    return ValueListenableBuilder(
      valueListenable: _isShowBottomSheetNotifier,
      builder: (context, value, child) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: widget.physics,
          itemCount: allPredictions.length,
          itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () {
              if (index < allPredictions.length) {
                widget.itmClick!(allPredictions[index]);
                if (!widget.isLatLngRequired) return;

                getPlaceDetailsFromPlaceId(allPredictions[index]);
                removeOverlay();
                Navigator.pop(context);
              }
            },
            child: Container(
              decoration: widget.suggestionDecoration,
              padding: const EdgeInsets.all(10),
              child: Text(
                allPredictions[index].description!,
                style: widget.predictionsStyle ?? widget.style,
              ),
            ),
          ),
        );
      },
    );
  }

  void removeBottomSheet() {
    if (_bottomSheetVisible) {
      Navigator.pop(context);
    }
  }

  void removeOverlay() {
    allPredictions.clear();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _overlayEntry!.markNeedsBuild();
  }

  Future<void> getPlaceDetailsFromPlaceId(Prediction prediction) async {
    try {
      final prefix = widget.proxyURL ?? "";
      final url =
          "${prefix}https://maps.googleapis.com/maps/api/place/details/json?placeid=${prediction.placeId}&key=${widget.googleAPIKey}";
      final response = await _dio.get(
        url,
      );

      final placeDetails = PlaceDetails.fromJson(response.data);

      prediction.lat = placeDetails.result!.geometry!.location!.lat.toString();
      prediction.lng = placeDetails.result!.geometry!.location!.lng.toString();

      widget.getPlaceDetailWithLatLng!(prediction);
    } catch (e) {
      rethrow;
    }
  }
}

class PlaceType {
  final String apiString;

  const PlaceType(this.apiString);

  static const geocode = PlaceType("geocode");
  static const address = PlaceType("address");
  static const establishment = PlaceType("establishment");
  static const region = PlaceType("(region)");
  static const cities = PlaceType("(cities)");
}

PlacesAutocompleteResponse parseResponse(Map responseBody) =>
    PlacesAutocompleteResponse.fromJson(responseBody as Map<String, dynamic>);

PlaceDetails parsePlaceDetailMap(Map responseBody) => PlaceDetails.fromJson(responseBody as Map<String, dynamic>);

typedef ItemClick = void Function(Prediction postalCodeResponse);
typedef GetPlaceDetailswWithLatLng = void Function(Prediction postalCodeResponse);
typedef OverlayContainer = Widget Function(Widget overlayChild);
