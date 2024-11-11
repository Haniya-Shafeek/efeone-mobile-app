import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/leave_application.dart';
import 'package:efeone_mobile/widgets/cust_textfield.dart';

class LeaveApplicationScreen extends StatelessWidget {
  const LeaveApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);
    controller.loadSharedPrefs();

    return WillPopScope(
      onWillPop: () async {
        controller.clearValues();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: 90,
            child: Image.asset('assets/images/efeone Logo.png'),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FutureBuilder(
            future: controller.fetchLeaveDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator(color: primaryColor,));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}', // Show the actual error message
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Consumer<LeaveRequestProvider>(
                      builder: (context, provider, child) {
                        return Form(
                          key: provider.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const custom_text(
                                  text: 'Employee id',
                                  fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: custom_text(
                                    text: provider.empid.toString(),
                                    fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              const custom_text(
                                  text: 'Employee Name',
                                  fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: custom_text(
                                    text: provider.empname.toString(),
                                    fontSize: 17),
                              ),
                              const SizedBox(height: 16),
                              const custom_text(
                                  text: "Leave Type",
                                  fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: provider.leaveType,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  items: controller.lwps!.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    provider.setLeaveType(value);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "please select Log Type";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const custom_text(
                                            text: "Start Date",
                                            fontWeight: FontWeight.bold),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              provider.pickStartDate(context),
                                          child: AbsorbPointer(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: cust_textfield(
                                                controller:
                                                    TextEditingController(
                                                  text: provider.startDate !=
                                                          null
                                                      ? "${provider.startDate!.day}/${provider.startDate!.month}/${provider.startDate!.year}"
                                                      : 'DD / MM / YY',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      value == 'DD / MM / YY') {
                                                    return "Select Start Date";
                                                  }
                                                  return null;
                                                },
                                                text: '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const custom_text(
                                            text: "End Date",
                                            fontWeight: FontWeight.bold),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () =>
                                              provider.pickEndDate(context),
                                          child: AbsorbPointer(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: cust_textfield(
                                                controller:
                                                    TextEditingController(
                                                  text: provider.endDate != null
                                                      ? "${provider.endDate!.day}-${provider.endDate!.month}-${provider.endDate!.year}"
                                                      : 'DD / MM / YY',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      value == 'DD / MM / YY') {
                                                    return "Select End Date";
                                                  }
                                                  return null;
                                                },
                                                text: '',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: provider.isHalfDay,
                                    onChanged: (value) {
                                      provider.setHalfDay(value!);
                                    },
                                  ),
                                  const custom_text(
                                      text: 'Half Day',
                                      fontWeight: FontWeight.bold),
                                ],
                              ),
                              if (provider.isHalfDay) ...[
                                const SizedBox(height: 12),
                                const custom_text(
                                    text: "Half Day Date",
                                    fontWeight: FontWeight.bold),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () =>
                                      provider.pickHalfDayDate(context),
                                  child: AbsorbPointer(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: cust_textfield(
                                        controller: TextEditingController(
                                          text: provider.halfDayDate != null
                                              ? "${provider.halfDayDate!.day}-${provider.halfDayDate!.month}-${provider.halfDayDate!.year}"
                                              : 'DD / MM / YY',
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty ||
                                              value == 'DD / MM / YY') {
                                            return "Select Halfday Date";
                                          }
                                          return null;
                                        },
                                        text: '',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              if (provider.dateValidationError != null)
                                custom_text(
                                    text: provider.dateValidationError!,
                                    color: Colors.red),
                              const SizedBox(height: 10),
                              const custom_text(
                                  text: "Reason", fontWeight: FontWeight.bold),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: cust_textfield(
                                  lines: 4,
                                  controller: provider.reasonController,
                                  text: 'Please enter reason',
                                ),
                              ),
                              const SizedBox(height: 25),
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (provider.formKey.currentState
                                              ?.validate() ==
                                          true) {
                                        if (provider.validateDates()) {
                                          final leaveType =
                                              controller.leaveType!;
                                          final fromDate = controller.startDate!
                                              .toIso8601String();
                                          final toDate = controller.endDate!
                                              .toIso8601String();
                                          final halfDay =
                                              controller.isHalfDay ? 1 : 0;
                                          final halfDayDate =
                                              controller.isHalfDay
                                                  ? controller.halfDayDate!
                                                      .toIso8601String()
                                                  : '';
                                          final totalLeaveDays = controller
                                              .calculateTotalLeaveDays();
                                          final reason =
                                              controller.reasonController.text;
                                          final leaveApprover =
                                              controller.approver!;
                                          const followViaEmail = 1;
                                          final postingDate =
                                              DateTime.now().toIso8601String();
                                          controller.postLeaveType(
                                              leaveType,
                                              fromDate,
                                              toDate,
                                              halfDay,
                                              halfDayDate,
                                              totalLeaveDays,
                                              reason,
                                              leaveApprover,
                                              followViaEmail,
                                              postingDate,
                                              context);
                                        } else {
                                          controller.validateDates();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const custom_text(
                                      text: "Submit",
                                      color: tertiaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
