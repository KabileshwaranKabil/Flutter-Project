import 'package:hive/hive.dart';
import 'focus_session.dart';

class FocusTechniqueAdapter extends TypeAdapter<FocusTechnique> {
  @override
  final int typeId = 13;

  @override
  FocusTechnique read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FocusTechnique.standard;
      case 1:
        return FocusTechnique.feynman;
      case 2:
        return FocusTechnique.srs_review;
      default:
        return FocusTechnique.standard;
    }
  }

  @override
  void write(BinaryWriter writer, FocusTechnique obj) {
    switch (obj) {
      case FocusTechnique.standard:
        writer.writeByte(0);
        break;
      case FocusTechnique.feynman:
        writer.writeByte(1);
        break;
      case FocusTechnique.srs_review:
        writer.writeByte(2);
        break;
    }
  }
}