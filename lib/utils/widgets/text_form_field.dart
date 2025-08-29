import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class CustomField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final bool showRedStar;
  final String? prefixText;
  final String? errorText;
  final bool isDropDown;
  final bool? readOnly;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction; // <-- Added
  final bool obscureText;
  final int? maxLines;
  final void Function()? onTap;
  final void Function()? suffixIconOnTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const CustomField({
    super.key,
    this.hintText,
    this.labelText,
    this.showRedStar = false,
    this.prefixText,
    this.errorText,
    this.isDropDown = false,
    this.suffixIcon,
    this.suffixWidget,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction, // <-- Added
    this.obscureText = false,
    this.readOnly,
    this.suffixIconOnTap,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_shouldShowLabel()) ...[_buildExternalLabel(context, locale), SizedBox(height: 0.5.h)],

        TextFormField(
          cursorColor: Theme.of(context).colorScheme.primary,
          onTap: onTap,
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction, // <-- Added
          obscureText: obscureText,
          readOnly: readOnly ?? false,
          onChanged: onChanged,
          maxLines: maxLines,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(
            color: Theme.of(context).dividerColor,
            fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
            fontSize: 5.sp,
          ),
          decoration: InputDecoration(
            alignLabelWithHint: true,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,

            hintText: hintText?.tr(),
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
              fontSize: 5.sp,
            ),

            prefixText: prefixText?.tr(),
            prefixStyle: TextStyle(
              color: Theme.of(context).dividerColor,
              fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
              fontSize: 5.sp,
            ),

            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
              fontSize: 4.5.sp,
            ),

            suffixIcon:
                suffixWidget ??
                IconButton(
                  icon: Icon(
                    (isDropDown && suffixWidget == null && suffixIcon == null)
                        ? context.locale.languageCode == 'en'
                              ? Icons.keyboard_arrow_right
                              : Icons.keyboard_arrow_left
                        : suffixIcon,
                    color: isDropDown ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: suffixIconOnTap,
                ),

            floatingLabelBehavior: FloatingLabelBehavior.never,
            errorText: errorText,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.5.w),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(76)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.5.w),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(76)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.5.w),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(76)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.5.w),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 4.2.w),
          ),
        ),
      ],
    );
  }

  bool _shouldShowLabel() {
    return labelText != null || (prefixText != null && labelText != null) || showRedStar;
  }

  Widget _buildExternalLabel(BuildContext context, Locale locale) {
    List<TextSpan> spans = [];

    if (showRedStar) {
      spans.add(
        TextSpan(
          text: '* ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
            fontSize: 5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (prefixText != null) {
      spans.add(
        TextSpan(
          text: '${prefixText!.tr()} ',
          style: TextStyle(
            color: Theme.of(context).dividerColor,
            fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
            fontSize: 5.sp,
          ),
        ),
      );
    }

    if (labelText != null) {
      spans.add(
        TextSpan(
          text: labelText!.tr(),
          style: TextStyle(
            color: Theme.of(context).dividerColor,
            fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
            fontSize: 5.sp,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class LeftAlignedTextFormField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final bool showRedStar;
  final String? prefixText;
  final String? errorText;
  final bool isDropDown;
  final bool? readOnly;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final void Function()? onTap;
  final void Function()? suffixIconOnTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;

  const LeftAlignedTextFormField({
    super.key,
    this.hintText,
    this.textInputAction,
    this.labelText,
    this.showRedStar = false,
    this.prefixText,
    this.errorText,
    this.isDropDown = false,
    this.suffixIcon,
    this.suffixWidget,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly,
    this.suffixIconOnTap,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.maxLines,
  });

  @override
  State<LeftAlignedTextFormField> createState() => _LeftAlignedTextFormFieldState();
}

class _LeftAlignedTextFormFieldState extends State<LeftAlignedTextFormField> {
  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isRTL = locale.languageCode == 'ar' || locale.languageCode == 'ku';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[CustomText(text: widget.labelText!), SizedBox(height: 0.5.h)],
        Directionality(
          textDirection: TextDirection.ltr, // Force LTR for the input field
          child: TextFormField(
            textInputAction: widget.textInputAction,
            cursorColor: Theme.of(context).colorScheme.primary,
            onTap: widget.onTap,
            controller: widget.controller,
            validator: (value) {
              if (widget.validator != null) {
                final error = widget.validator!(value);
                if (error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showError(context, error, isRTL);
                  });
                }
                return null; // Prevent built-in error display
              }
              return null;
            },
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly ?? false,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            onFieldSubmitted: widget.onSubmitted,
            textAlign: TextAlign.left, // Explicit left alignment
            style: TextStyle(
              color: Theme.of(context).dividerColor,
              fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
              fontSize: 5.sp,
            ),
            decoration: InputDecoration(
              alignLabelWithHint: true,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              hintText: widget.hintText?.tr(),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
                fontSize: 5.sp,
              ),
              prefixText: widget.prefixText?.tr(),
              prefixStyle: TextStyle(
                color: Theme.of(context).dividerColor,
                fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
                fontSize: 5.sp,
              ),
              errorStyle: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
                fontSize: 4.5.sp,
              ),
              errorText: null,
              suffixIcon:
                  widget.suffixWidget ??
                  (widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: widget.isDropDown ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: widget.suffixIconOnTap,
                        )
                      : null),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.showRedStar)
                    Padding(
                      padding: EdgeInsets.only(right: 1.w),
                      child: CustomText(text: '*', color: Theme.of(context).colorScheme.error, fontSize: 6, fontWeight: FontWeight.w700),
                    ),
                  if (widget.prefixText != null) CustomText(text: widget.prefixText ?? ''),
                  if (widget.hintText != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.prefixText != null
                            ? 2.w
                            : widget.showRedStar
                            ? 1.w
                            : 0,
                      ),
                      child: CustomText(
                        text: widget.hintText ?? '',
                        color: widget.isDropDown ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.5.w),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(77)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.5.w),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(77)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.5.w),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(77)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.5.w),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 4.2.w),
            ),
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: _errorNotifier,
          builder: (context, error, _) {
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
              child: Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
                    fontSize: 4.5.sp,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  void _showError(BuildContext context, String error, bool isRTL) {
    _errorNotifier.value = error;
  }

  @override
  void dispose() {
    _errorNotifier.dispose();
    super.dispose();
  }
}
