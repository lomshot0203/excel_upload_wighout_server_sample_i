/* 엑셀업로드용 헤더*/
var cHeader = ['sclas_cd'/*소분류*/, 'in_cd'/*그룹코드*/,'asst_nm'/*품명*/ ,'sch_model'/*모델명*/ ,'sch_vendor' /*제작사*/,'sch_barcode'/*바코드*/,'install_loc'/*기자재위치*/,'sch_col_cd'/*부서(원)*/,'sch_dept_cd'/*부서1*/,'sch_dept_cd2'/*부서2*/
            			,'sch_dept_cd3'/*부서3*/,'asst_no'/*자산번호*/,'use_usage_div'/*물품용도*/,'get_amt'/*취득수량*/,'get_price'/*취득금액*/,'get_dt'/*취득일자*/,'get_unit_price'/*단가*/,'dis_dt'/*정리일자*/,'est_life'/*내용년수*/,'sch_accessory'/*악세사리*/
            			,'sch_repair'/*수리내역*/,'seq_no'/*고유(식별번호)*/,'rfid_no'/*관리번호(rfid)*/,'vendor'/*납품자*/,'sch_remark'/*비고*/];
                  
=============>>>> 호출

 function fn_excelUpload(fileObj) {

            if(!checkFileType($("#excelUpload").val())){
                alert("엑셀 파일만 업로드 해주세요.");
                setFilePath("");
                return false;
            }

            if(confirm("업로드 하시겠습니까?")){
                grid0011.reClearAll();
                appJs.getExcelData(fileObj, cHeader, function (val) {
                    val.splice(0, 1);
                    for (var aRow in val) {
                        val[aRow].rowStat="C";
                        val[aRow].sch_status = '01'; /*물품상태 (보관중)*/
                        val[aRow].sch_rent_yn = 'Y'; /*대여가능여부*/
                        val[aRow].get_price = appJs.replaceAll(val[aRow].get_price, ",", ""); /*취득금액*/
                        val[aRow].get_amt = appJs.replaceAll(val[aRow].get_amt, ",", ""); /*취득수량*/
                        val[aRow].get_unit_price = appJs.replaceAll(val[aRow].get_unit_price, ",", ""); /*단가*/
                        val[aRow].est_life = appJs.replaceAll(val[aRow].est_life, ",", ""); /*내용년수*/
                        val[aRow].dis_dt = getDate(val[aRow].dis_dt);
                        val[aRow].get_dt = getDate(val[aRow].get_dt);
					}
                    grid0011.reGridBind(val);
                    initFileValue();
                });
            } else {
                initFileValue();
			}
        }
        


=============>>>> 실행

/*********************************************
 * 함수명 : appJs.getExcelData
 * 설 명 : 엑셀데이터를 스크립트로 가져온다.
 * @param fileObj 업로드파일객체
 * @param header 헤더배열
 * @param func 콜백함수
 * ex) appJs.getExcelData(fileObj, header, func)
 *********************************************/
appJs.getExcelData = function (fileObj, header, func) {
    var selectedFile = fileObj[0];
    var reader = new FileReader();
    reader.readAsArrayBuffer(selectedFile);
    reader.onload = function(evt) {
        if(evt.target.readyState == FileReader.DONE) {
            if(typeof Uint8Array !== 'undefined' && !Uint8Array.prototype.slice) {
                Uint8Array.prototype.slice = function(start, end) {
                    if(start == null) start = 0;
                    if(start < 0) {start += this.length; if(start < 0) start = 0;};
                    if(start >= this.length) return new Uint8Array(0);
                    if(end == null) end = this.length;
                    if(end < 0) { end += this.length; if(end < 0) end = 0; }
                    if(end > this.length) end = this.length;
                    if(start > end) return new Uint8Array(0);
                    var out = new Uint8Array(end - start);
                    while(start <= --end) out[end - start] = this[end];

                    return out;
                };
            }

            var data = new Uint8Array(evt.target.result);
            var workbook = XLSX.read(data, {type: 'array', cellDates: true, dateNF: 'yyyy-mm-dd;@'});
            var toJSON = null;

            workbook.SheetNames.forEach(function(item, index, array) {
                if (index == 0) {
                    toJSON = XLSX.utils.sheet_to_json(workbook.Sheets[item], {header:cHeader});
                }
            });
        }
        func(toJSON);
    };
};


=============>>>> 그외

/*파일업로드시에 <input type='file'></input> 의 value 초기화*/
function initFileValue() {
            if (/(MSIE|Trident)/.test(navigator.userAgent)) { 
                // ie 일때 input[type=file] init.
                $("#excelUpload").replaceWith( $("#excelUpload").clone(true) );
            } else {
                // other browser 일때 input[type=file] init.
                $("#excelUpload").val("");
            }
		}

