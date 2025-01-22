import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:efeone_mobile/utilities/constants.dart';

class CheckinPermissionScreen extends StatefulWidget {
  const CheckinPermissionScreen({super.key});

  @override
  _CheckinPermissionScreenState createState() =>
      _CheckinPermissionScreenState();
}

class _CheckinPermissionScreenState extends State<CheckinPermissionScreen> {
  late CheckinPermissionProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<CheckinPermissionProvider>(context, listen: false);
    provider.loadSharedPrefs();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        provider.clearValues();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: screenWidth * 0.2,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
        ),
        body: Consumer<CheckinPermissionProvider>(
          builder: (context, provider, child) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          custom_text(
                            text: 'Apply for ECP',
                            fontSize: 23,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildLabeledContainer(
                          'Employee ID', provider.empid.toString()),
                      _buildLabeledContainer(
                          'Employee Name', provider.empname.toString()),
                      SizedBox(height: screenHeight * 0.02),
                      _buildDateSection(screenWidth, provider),
                      SizedBox(height: screenHeight * 0.02),
                      _buildLogTypeSection(screenWidth, provider),
                      SizedBox(height: screenHeight * 0.02),
                      if (provider.selectedLogType != null)
                        _buildTimeSection(screenWidth, provider),
                      SizedBox(height: screenHeight * 0.01),
                      _buildReasonSection(screenWidth, provider),
                      const SizedBox(height: 10),
                      _buildSubmitButton(provider),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabeledContainer(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(
      double screenWidth, CheckinPermissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_text(
          text: 'Date',
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.035,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => provider.selectDate(context),
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: TextEditingController(
                  text: provider.selectedDate != null
                      ? '${provider.selectedDate!.toLocal()}'.split(' ')[0]
                      : 'DD / MM / YY',
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value == 'DD / MM / YY') {
                    return "Please select date";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 13, 64, 106),
                  ),
                  border: InputBorder.none,
                  hintText: 'Select Date',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogTypeSection(
      double screenWidth, CheckinPermissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_text(
          text: 'Log Type',
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.035,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: provider.selectedLogType,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            items: <String>['IN', 'OUT'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              provider.selectLogType(value!);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select log type";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(
      double screenWidth, CheckinPermissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_text(
          text: provider.selectedLogType == 'IN'
              ? 'Expected Arrival Time'
              : 'Expected Leaving Time',
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.045,
        ),
        SizedBox(height: screenWidth * 0.02),
        GestureDetector(
          onTap: () => provider.selectedLogType == 'IN'
              ? provider.selectarrivalTime(context)
              : provider.selectLeavingTime(context),
          child: AbsorbPointer(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: TextEditingController(
                  text: provider.selectedLogType == 'IN'
                      ? (provider.selectedarrivalTime != null
                          ? provider.selectedarrivalTime!.format(context)
                          : '')
                      : (provider.selectedLeavingTime != null
                          ? provider.selectedLeavingTime!.format(context)
                          : ''),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Time',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select time";
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSection(
      double screenWidth, CheckinPermissionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_text(
          text: 'Reason',
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.035,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12.0),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: provider.reasonController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the reason';
              }
              return null;
            },
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Please enter reason',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CheckinPermissionProvider provider) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            if (provider.formKey.currentState?.validate() ?? false) {
              final employeeid = provider.empid.toString();
              final date = provider.selectedDate.toString();
              final logtype = provider.selectedLogType.toString();
              final arrivaltime = provider.selectedarrivalTime.toString();
              final leavingtime = provider.selectedLeavingTime.toString();
              final reason = provider.reasonController.text;

              provider.submitCheckinPermission(
                empId: employeeid,
                date: date,
                logType: logtype,
                arrivalTime: arrivaltime,
                leavingTime: leavingtime,
                reason: reason,
                context: context,
              );
            }
          },
          child: const custom_text(
            text: 'Submit',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
