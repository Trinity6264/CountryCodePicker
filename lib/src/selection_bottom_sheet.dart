import 'package:country_code_picker/src/components/bottom_sheet_handler.dart';
import 'package:flutter/material.dart';

import 'country_code.dart';
import 'country_localizations.dart';

/// selection dialog used for selection of the country code
class SelectionBottomSheet extends StatefulWidget {
  final List<CountryCode> elements;
  final String? selectedElement;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final bool hideCloseIcon;
  final Icon? closeIcon;

  /// Background color of SelectionBottomSheet
  final Color? backgroundColor;

  /// Boxshaow color of SelectionBottomSheet that matches CountryCodePicker barrier color
  final Color? barrierColor;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;

  SelectionBottomSheet(
    this.elements,
    this.favoriteElements, {
    Key? key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.textStyle,
    this.boxDecoration,
    this.selectedElement,
    this.showFlag,
    this.flagDecoration,
    this.flagWidth = 32,
    this.size,
    this.backgroundColor,
    this.barrierColor,
    this.hideSearch = false,
    this.hideCloseIcon = false,
    this.closeIcon,
    this.dialogItemPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
  })  : searchDecoration = searchDecoration.prefixIcon == null
            ? searchDecoration.copyWith(prefixIcon: const Icon(Icons.search))
            : searchDecoration,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<SelectionBottomSheet> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;
  CountryCode? selectedCountryCode;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.hardEdge,
        width: widget.size?.width ?? MediaQuery.of(context).size.width,
        height:
            widget.size?.height ?? MediaQuery.of(context).size.height * 0.85,
        decoration: widget.boxDecoration ??
            BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const BottomSheetHandler(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Nationality",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: Color(0xff1A1B1F),
                    ),
                  ),
                  if (!widget.hideCloseIcon)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xfff4f3f8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xff012150)),
                      ),
                    ),
                ],
              ),
            ),
            if (selectedCountryCode != null)
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                    onTap: () {
                      _selectItem(selectedCountryCode!);
                    },
                    child: Padding(
                      padding: widget.dialogItemPadding,
                      child: _buildOption(selectedCountryCode!),
                    )),
              ),
            const Divider(),
            if (!widget.hideSearch)
              Padding(
                padding: widget.searchPadding,
                child: TextField(
                  style: widget.searchStyle,
                  decoration: widget.searchDecoration,
                  onChanged: _filterElements,
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  widget.favoriteElements.isEmpty
                      ? const DecoratedBox(decoration: BoxDecoration())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.favoriteElements.map((f) => InkWell(
                                onTap: () {
                                  _selectItem(f);
                                },
                                child: Padding(
                                  padding: widget.dialogItemPadding,
                                  child: _buildOption(f),
                                ))),
                            const Divider(),
                          ],
                        ),
                  if (filteredElements.isEmpty)
                    _buildEmptySearchWidget(context)
                  else
                    ...filteredElements.map((e) => InkWell(
                        onTap: () {
                          _selectItem(e);
                        },
                        child: Padding(
                          padding: widget.dialogItemPadding,
                          child: _buildOption(e),
                        ))),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildOption(CountryCode e) {
    return SizedBox(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (widget.showFlag!)
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: widget.flagDecoration,
                clipBehavior:
                    widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
                child: Image.asset(
                  e.flagUri!,
                  package: 'country_code_picker',
                  width: widget.flagWidth,
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Text(
              widget.showCountryOnly!
                  ? e.toCountryStringOnly()
                  : e.toLongString(),
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(
      child: Text(CountryLocalizations.of(context)?.translate('no_country') ??
          'No country found'),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    fetchSelected(widget.selectedElement ?? "Ghana");
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements.where((e) {
        return e.code!.contains(s) ||
            e.dialCode!.contains(s) ||
            e.name!.toUpperCase().contains(s);
      }).toList();
    });
  }

  void fetchSelected(String value) {
    selectedCountryCode = filteredElements.firstWhere((e) =>
        e.code!.contains(value.toUpperCase()) ||
        e.dialCode!.contains(value.toUpperCase()) ||
        e.name!.toUpperCase().contains(value.toUpperCase()));
    setState(() {});
  }

  void _selectItem(CountryCode e) {
    fetchSelected(e.name!);
    Navigator.pop(context, e);
  }
}
