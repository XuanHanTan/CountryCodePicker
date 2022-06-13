import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? textStyle;
  final TextStyle? searchTitleStyle;
  final String searchTitleText;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final Icon? closeIcon;
  final Icon? searchIcon;
  final Function? onPress;
  final Color? dividerColor;

  /// Background color of SelectionDialog
  final Color? backgroundColor;

  /// Boxshaow color of SelectionDialog that matches CountryCodePicker barrier color
  final Color? barrierColor;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  SelectionDialog(
    this.elements,
    this.favoriteElements, {
    Key? key,
    this.showCountryOnly,
    required this.searchDecoration,
    this.searchStyle,
    this.textStyle,
    this.searchTitleStyle,
    this.searchTitleText = "Pick a country code",
    this.boxDecoration,
    this.emptySearchBuilder,
    this.showFlag,
    this.flagWidth = 32,
    this.flagDecoration,
    this.size,
    this.hideSearch = false,
    this.closeIcon,
    this.searchIcon,
    this.onPress,
    this.dividerColor,
    this.backgroundColor,
    this.barrierColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;
  bool _isSearch = false;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    return Container(
        clipBehavior: Clip.hardEdge,
        width: widget.size?.width ?? mediaQueryData.size.width,
        decoration: widget.boxDecoration ??
            BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: widget.barrierColor ?? Colors.grey.withOpacity(1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
        child: Padding(
          padding: EdgeInsets.only(
              left: (10.0 + mediaQueryData.padding.left),
              right: (10.0 + mediaQueryData.padding.right)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 10),
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              Container(height: 10),
              Padding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: _isSearch
                          ? TextField(
                              style: widget.searchStyle,
                              decoration: widget.searchDecoration,
                              onChanged: _filterElements,
                            )
                          : Text(
                              widget.searchTitleText,
                              style: widget.searchTitleStyle,
                            ),
                    ),
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: Material(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0)),
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0)),
                            radius: 28,
                            onTap: () {
                              setState(() {
                                _isSearch = !_isSearch;
                              });
                            },
                            child: !_isSearch
                                ? widget.searchIcon!
                                : widget.closeIcon!,
                          )),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(bottom: 2),
              ),
              Expanded(
                child: ListView(
                  children: [
                    widget.favoriteElements.isEmpty
                        ? const DecoratedBox(decoration: BoxDecoration())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...widget.favoriteElements.map(
                                (f) => SimpleDialogOption(
                                  child: _buildOption(f),
                                  onPressed: () {
                                    _selectItem(f);
                                  },
                                ),
                              ),
                              Divider(
                                color: widget.dividerColor,
                              ),
                              //need divider colour
                            ],
                          ),
                    if (filteredElements.isEmpty)
                      _buildEmptySearchWidget(context)
                    else
                      ...filteredElements.map(
                        (e) => SimpleDialogOption(
                          child: _buildOption(e),
                          onPressed: () {
                            _selectItem(e);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildOption(CountryCode e) {
    return Container(
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
      child: Text('No country found'),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code!.contains(s) ||
              e.dialCode!.contains(s) ||
              e.name!.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    widget.onPress!(e);
    Navigator.pop(context);
  }
}
