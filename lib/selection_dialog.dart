import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
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
  final Icon? closeIcon;
  final Icon? searchIcon;
  final Function? onPress;
  final Color? dividerColor;

  /// Search text field color of SelectionDialog
  final Color? searchTextFieldColor;

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
    this.searchTextFieldColor,
    this.backgroundColor,
    this.barrierColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;
  late TextEditingController searchTextFieldController;
  bool _isLoadingCountries = false;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: widget.searchTextFieldColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: TextField(
                        maxLines: 1,
                        style: widget.searchStyle,
                        controller: searchTextFieldController,
                        decoration: widget.searchDecoration.copyWith(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none),
                        onChanged: _filterElements,
                      ),)
                    ),
                  ),
                  searchTextFieldController.text != ""
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(28.0)),
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(28.0)),
                                    onTap: () async {
                                      searchTextFieldController.text = "";
                                      FocusScope.of(context).unfocus();
                                      loadDefaultFilteredElements();
                                    },
                                    child: widget.closeIcon!,
                                  )),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                          ],
                          mainAxisSize: MainAxisSize.min,
                        )
                      : const SizedBox()
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          const SizedBox(height: 20),
          Expanded(
              child: _isLoadingCountries
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(children: [
                      widget.favoriteElements.isEmpty
                          ? const DecoratedBox(decoration: BoxDecoration())
                          : Column(
                              children: [
                                _buildCountryList(widget.favoriteElements),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Divider(
                                    color: widget.dividerColor,
                                  ),
                                )
                              ],
                            ),
                      _buildCountryList(filteredElements)
                    ])),
        ],
      ),
    );
  }

  Widget _buildCountryList(List<CountryCode> countryList) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final country = countryList[index];

        return _buildOption(country, () {
          _selectItem(country);
        });
      },
      separatorBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            color: widget.dividerColor,
          ),
        );
      },
      itemCount: countryList.length,
    );
  }

  Widget _buildOption(CountryCode e, void Function() onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: widget.showFlag!
          ? Container(
              decoration: widget.flagDecoration,
              clipBehavior:
                  widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
              child: Image.asset(
                e.flagUri!,
                package: 'country_code_picker',
                width: widget.flagWidth,
              ),
            )
          : null,
      title: Text(
        e.toCountryStringOnly(),
        overflow: TextOverflow.fade,
        style: widget.textStyle,
      ),
      subtitle: e.localName() != e.toCountryStringOnly()
          ? Text(e.localName() ?? "")
          : null,
      trailing: Text(e.dialCode ?? "", style: widget.textStyle),
    );
  }

  @override
  void initState() {
    super.initState();
    searchTextFieldController = TextEditingController();
    loadDefaultFilteredElements();
  }

  void loadDefaultFilteredElements() {
    setState(() {
      filteredElements = widget.elements
          .where((element) => !widget.favoriteElements
              .any((favouriteElement) => element.code == favouriteElement.code))
          .toList();
    });
  }

  void _filterElements(String s) {
    s = s.toUpperCase();

    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              (e.code!.contains(s) ||
                  e.dialCode!.contains(s) ||
                  e.name!.toUpperCase().contains(s)) &&
              !widget.favoriteElements
                  .any((favouriteElement) => e.code == favouriteElement.code))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    widget.onPress!(e);
    Navigator.pop(context);
  }
}
