import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseView<T> extends ConsumerStatefulWidget {
  const BaseView({
    Key? key,
    required this.viewModel,
    required this.onPageBuilder,
    required this.onModelReady,
    this.onDispose,
  }) : super(key: key);
  final Widget Function(BuildContext context, T value) onPageBuilder;
  final T viewModel;
  final void Function(WidgetRef model) onModelReady;
  final VoidCallback? onDispose;

  @override
  ConsumerState createState() => _BaseViewState<T>();
}

class _BaseViewState<T> extends ConsumerState<BaseView<T>> {
  late T model;
  @override
  void initState() {
    model = widget.viewModel;
    widget.onModelReady(ref);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onDispose != null) widget.onDispose?.call();
  }

  @override
  Widget build(BuildContext context) {
    // if (ref.read(talepprovider).customerAktifTalepVarMi(customer)) {
    //   //aktif bildirim ve talepler için bir banner aç.
    //   // aktifSiparisler.addAll(ref.read(talepprovider).customerAktifTalepleriGetir(customer)!);
    // }
    return widget.onPageBuilder(context, model);
  }
}
