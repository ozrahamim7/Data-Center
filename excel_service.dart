import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:srv_hub/models/server_model.dart';
import 'package:file_picker/file_picker.dart';

class ExcelService {
  Future<Uint8List> createExcelData(List<ServerModel> servers) async {
    final excel = Excel.createExcel();
    final sheet = excel['Servers'];

    final headers = ['Name', 'Vendor', 'Switch', 'Panel', 'Location', 'IP Address', 'Port', 'Description', 'Status', 'Cabinet', 'Cabinet Location', 'ID'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: '#E0E0E0',
      );
    }

    for (var i = 0; i < servers.length; i++) {
      final server = servers[i];
      final rowIndex = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = server.name;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = server.vendor;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = server.switchName;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = server.panel;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value = server.location;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = server.ipAddress;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = server.port;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).value = server.description;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).value = ServerModel.getStateString(server.state);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex)).value = server.cabinet;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex)).value = server.cabinetLocation;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: rowIndex)).value = server.uuid;

      final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex));
      switch (server.state) {
        case ServerState.active:
          statusCell.cellStyle = CellStyle(
            backgroundColorHex: '#DCEDC8',
            fontColorHex: '#33691E',
          );
          break;
        case ServerState.maintenance:
          statusCell.cellStyle = CellStyle(
            backgroundColorHex: '#FFECB3',
            fontColorHex: '#FF8F00',
          );
          break;
        case ServerState.offline:
          statusCell.cellStyle = CellStyle(
            backgroundColorHex: '#FFCDD2',
            fontColorHex: '#C62828',
          );
          break;
      }
    }

    for (var i = 0; i < headers.length; i++) {
      sheet.setColWidth(i, 20.0);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception("Failed to encode Excel file");
    }
    return Uint8List.fromList(bytes);
  }

  Future<bool> _saveFileForAndroid(Uint8List excelData, String fileName) async {
    try {
      if (!fileName.toLowerCase().endsWith('.xlsx')) {
        fileName += '.xlsx';
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) return false;

      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(excelData);

      return true;
    } catch (e) {
      print('Error in _saveFileForAndroid: $e');
      return false;
    }
  }

  Future<bool> exportExcel(List<ServerModel> servers, {String fileName = 'srv_hub_servers'}) async {
    try {
      final excelData = await createExcelData(servers);

      if (kIsWeb) {
        await _exportForWeb(excelData, fileName);
      } else {
        await _saveFileForAndroid(excelData, fileName);
      }

      return true;
    } catch (e) {
      print('Error exporting Excel file: $e');
      return false;
    }
  }

  Future<void> _exportForWeb(Uint8List excelData, String fileName) async {
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: excelData,
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  Future<String> exportServersToExcel(List<ServerModel> servers) async {
    try {
      final fileName = 'srv_hub_servers_${DateTime.now().millisecondsSinceEpoch}';
      final success = await exportExcel(servers, fileName: fileName);

      if (!success) {
        throw Exception('Failed to export Excel file');
      }

      return fileName;
    } catch (e) {
      print('Error exporting servers to Excel: $e');
      rethrow;
    }
  }

  Future<List<ServerModel>> importServersFromExcel(Uint8List bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel['Servers'];
      final List<ServerModel> importedServers = [];
      final rows = sheet.rows;

      if (rows.length <= 1) {
        return [];
      }

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.isEmpty || row[0]?.value == null) continue;

        final name = _getCellStringValue(row[0]);
        final vendor = _getCellStringValue(row[1]);
        final switchName = _getCellStringValue(row[2]);
        final panel = _getCellStringValue(row[3]);
        final location = _getCellStringValue(row[4]);
        final ipAddress = _getCellStringValue(row[5]);
        final port = _getCellIntValue(row[6], defaultValue: 22);
        final description = _getCellStringValue(row[7]);
        final statusString = _getCellStringValue(row[8]);
        final cabinet = _getCellStringValue(row[9]);
        final cabinetLocation = _getCellStringValue(row[10]);

        String uuid = row.length > 11 ? _getCellStringValue(row[11]) : '';
        if (uuid.isEmpty) {
          uuid = DateTime.now().millisecondsSinceEpoch.toString() + '_' + importedServers.length.toString();
        }

        ServerState state = _parseServerState(statusString);

        final server = ServerModel(
          uuid: uuid,
          name: name,
          location: location,
          ipAddress: ipAddress,
          port: port,
          description: description,
          state: state,
          cabinet: cabinet,
          cabinetLocation: cabinetLocation,
          vendor: vendor,
          switchName: switchName,
          panel: panel,
        );

        importedServers.add(server);
      }

      return importedServers;
    } catch (e) {
      print('Error importing Excel file: $e');
      throw Exception('Failed to import servers from Excel: $e');
    }
  }

  String _getCellStringValue(dynamic cell) {
    if (cell == null) return '';
    return cell.value?.toString() ?? '';
  }

  int _getCellIntValue(dynamic cell, {int defaultValue = 0}) {
    if (cell == null) return defaultValue;
    if (cell.value == null) return defaultValue;

    try {
      if (cell.value is int) return cell.value;
      if (cell.value is double) return cell.value.toInt();
      return int.tryParse(cell.value.toString()) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  ServerState _parseServerState(String stateString) {
    final normalizedState = stateString.toLowerCase().trim();

    if (normalizedState.contains('active') || normalizedState.contains('online')) {
      return ServerState.active;
    } else if (normalizedState.contains('maintenance')) {
      return ServerState.maintenance;
    } else {
      return ServerState.offline;
    }
  }

  Future<List<ServerModel>> pickAndImportExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
        return [];
      }

      final bytes = result.files.first.bytes!;
      return await importServersFromExcel(bytes);
    } catch (e) {
      print('Error picking and importing Excel file: $e');
      rethrow;
    }
  }
}
