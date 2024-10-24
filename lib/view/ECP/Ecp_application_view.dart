import 'package:efeone_mobile/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/view/ECP/Ecp_list_view.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';

class CheckinPermissionScreen extends StatelessWidget {
  const CheckinPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<CheckinPermissionProvider>(context, listen: false);
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
        body: FutureBuilder(
          future: provider.loadSharedPrefs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else {
              return Consumer<CheckinPermissionProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Form(
                        key: provider.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Employee ID Section
                            custom_text(
                              text: 'Employee ID',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: custom_text(
                                text:
                                    provider.empid?.toString() ?? 'Loading...',
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Employee Name Section
                            custom_text(
                              text: 'Employee Name',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: custom_text(
                                text: provider.empname?.toString() ??
                                    'Loading...',
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Date Section
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03),
                                  ),
                                  child: TextFormField(
                                    controller: TextEditingController(
                                      text: provider.selectedDate != null
                                          ? '${provider.selectedDate!.toLocal()}'
                                              .split(' ')[0]
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
                            SizedBox(height: screenHeight * 0.02),

                            // Log Type Section
                            custom_text(
                              text: 'Log Type',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: provider.selectedLogType,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                items:
                                    <String>['IN', 'OUT'].map((String value) {
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
                            SizedBox(height: screenHeight * 0.02),

                            // Time Field Section
                            if (provider.selectedLogType != null) ...[
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
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(
                                          screenWidth * 0.03),
                                    ),
                                    child: TextFormField(
                                      controller: TextEditingController(
                                        text: provider.selectedLogType == 'IN'
                                            ? (provider.selectedarrivalTime !=
                                                    null
                                                ? provider.selectedarrivalTime!
                                                    .format(context)
                                                : '')
                                            : (provider.selectedLeavingTime !=
                                                    null
                                                ? provider.selectedLeavingTime!
                                                    .format(context)
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
                            SizedBox(height: screenHeight * 0.02),

                            // Reason Section
                            custom_text(
                              text: 'Reason',
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
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
                            SizedBox(height: screenHeight * 0.04),

                            // Apply Button Section
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (provider.formKey.currentState
                                            ?.validate() ??
                                        false) {
                                      final date =
                                          provider.selectedDate.toString();
                                      final logtype =
                                          provider.selectedLogType.toString();
                                      final arrivaltime = provider
                                          .selectedarrivalTime
                                          .toString();
                                      final leavingtime = provider
                                          .selectedLeavingTime
                                          .toString();
                                      final reason =
                                          provider.reasonController.text;

                                      provider.submitCheckinPermission(
                                        date: date,
                                        logType: logtype,
                                        arraivalTime: arrivaltime,
                                        leavingTime: leavingtime,
                                        reason: reason,
                                        context: context,
                                      );

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CheckinPermissionListScreen(),
                                          ));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Container(
                                          padding: EdgeInsets.all(
                                              screenWidth * 0.03),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                                screenWidth * 0.03),
                                          ),
                                          child: const Center(
                                            child: custom_text(
                                              text:
                                                  'Check-in request submitted!',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015),
                                    backgroundColor: primaryColor,
                                  ),
                                  child: custom_text(
                                    text: 'Apply',
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
