const oracledb = require("oracledb");
const dbConfig = require("./dbconfig.js");
var http = require("http");
var express = require("express");
var app = express();
var PORT = process.env.PORT || 8089;
let connection;
app.listen(PORT, function () {
  async function run() {
    try {
      connection = await oracledb.getConnection(dbConfig);
    } catch (e) {
      console.log(e);
    }
  }
  run();
  console.log("Server running on port " + PORT + ", Express is listening...");
});

app.get("/", function (req, res) {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.write("No Data Requested, so none is returned");
  res.end();
});

app.get("/popular-courses/:course_year/:course_term", function (req, res) {
  popularCourses(req, res);
});

app.get("/rating/courses/:year/:term", function (req, res) {
  ratingCourses(req, res);
});

app.get("/rating/teachers/:year/:term", function (req, res) {
  ratingTeachers(req, res);
});

app.get("/popular-teachers/:course_type/:course_year/:course_term/:ders_kod", function (req, res) {
    popularTeachers(req, res);
});

app.get("/all-retakes-profit", function (req, res) {
    allRetakesProfit(req, res);
});
app.get("/teachers/loading/:year/:term/:empId", function (req, res) {
  teachersLoading(req, res);
});

app.get("/courses/:course_year/:course_term/:course_type", function (req, res) {
  coursesWithType(req, res);
});
app.get("/gpa/:studId", function (req, res) {
  gpa(req, res, 'total');
});
app.get("/gpa/:year/:term/:studId", function (req, res) {
  gpa(req, res, 'term');
});
app.get("/students/retake/:year/:term/:studId", function (req, res) {
  retakes(req, res, 'term');
});
app.get("/students/retake/:studId", function (req, res) {
  retakes(req, res, 'total');
});

app.get("/students/:year/:term", function (req, res) {
  allStudents(req, res);
});

app.get("/students/schedule/:year/:term/:id", function (req, res) {
  scheduleStudents(req, res);
});

app.get("/teachers/schedule/:year/:term/:id", function (req, res) {
  scheduleTeachers(req, res);
});

app.get("/students/NR/:year/:term", function (req, res) {
  studentsNR(req, res);
});

app.get("/teachers/:course_year/:course_term/", function (req, res) {
  allTeachers(req, res);
});
app.get("/courses/:course_year/:course_term/", function (req, res) {
  allCourses(req, res);
});

app.get("/teachers/clever-flow/:dersKod/:year/:term/:empId", function (req, res) {
  cleverFlow(req, res);
});
app.get("/teachers/:dersKod/:year/:term", function (req, res) {
  allTeachersDers(req, res);
});

function allRetakesProfit(req, res) {
  var funcPLSQL = 
  `BEGIN
    :res := calculateTotalRetakes();
  END;`;
  connection.execute(
    funcPLSQL,
    {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}},
    {},
    function (err, result) {
      if (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the all retakes",
            detailed_message: err.message,
          })
        );
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.outBinds));
      }
    }
  );
}

function teachersLoading(req, res) {
  var funcPLSQL = 
  `BEGIN
    :res := teacher_loading(:term, :year, :empId);
  END;`;
  connection.execute(
    funcPLSQL,
    {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}, year : req.params.year, term : req.params.term, empId: req.params.empId},
    {},
    function (err, result) {
      if (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the all retakes",
            detailed_message: err.message,
          })
        );
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.outBinds));
      }
    }
  );
}

function gpa(req, res, type) {
  var funcPLSQL;
  var binds;
  if (type == 'total') {
    funcPLSQL = 
    `BEGIN
      :res := calculateGPA_total(:studId);
    END;`;
    binds = {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}, studId: {type:oracledb.STRING, val:req.params.studId}}
  }
  else {
    funcPLSQL = 
    `BEGIN
      :res := calculateGPA_term(:studId, :term, :year);
    END;`;
    binds = {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}, studId: {type:oracledb.STRING, val:req.params.studId}, term : req.params.term, year: req.params.year};
  }
  connection.execute(
    funcPLSQL,
    binds,
    {},
    function (err, result) {
      if (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the all retakes",
            detailed_message: err.message,
          })
        );
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.outBinds));
      }
    }
  );
}

function retakes(req, res, type) {
  var funcPLSQL;
  var binds;
  if (type == 'total') {
    funcPLSQL = 
    `BEGIN
      :res := calculateSpentRetake_total(:studId);
    END;`;
    binds = {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}, studId: {type:oracledb.STRING, val:req.params.studId}}
  }
  else {
    funcPLSQL = 
    `BEGIN
      :res := calculateSpentRetake_term(:studId, :term, :year);
    END;`;
    binds = {res: {dir: oracledb.BIND_OUT, type: oracledb.NUMBER}, studId: {type:oracledb.STRING, val:req.params.studId}, term : req.params.term, year: req.params.year};
  }
  connection.execute(
    funcPLSQL,
    binds,
    {},
    function (err, result) {
      if (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the all retakes",
            detailed_message: err.message,
          })
        );
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.outBinds));
      }
    }
  );
}

function cleverFlow(req, res) {
  var funcPLSQL = 
  `BEGIN
    :res := most_clever_flow_students(:term, :year, :empId, :dersKod);
  END;`;
  connection.execute(
    funcPLSQL,
    {res: {dir: oracledb.BIND_OUT, type: oracledb.STRING},dersKod : {type: oracledb.STRING,val:req.params.dersKod}, year : req.params.year, term : req.params.term, empId: req.params.empId},
    {},
    function (err, result) {
      if (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the all retakes",
            detailed_message: err.message,
          })
        );
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify(result.outBinds));
      }
    }
  );
}

function coursesWithType(request, response) {
  var courseType = request.params.courseType;
  var selectStatement;
  if (courseType == 'lection')
  selectStatement = `SELECT distinct(ders_kod) FROM course_sections WHERE term = :course_term AND year = :course_year AND type IN ('L', 'N')`;
  else if (courseType = 'practice')
  selectStatement = `SELECT distinct(ders_kod) FROM course_sections WHERE term = :course_term AND year = :course_year AND type = 'P'`;

  connection.execute(
    selectStatement,
    {course_term: request.params.course_term, course_year: request.params.course_year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function popularCourses(request, response) {
  var selectStatement = `SELECT ders_kod FROM table(pkg_courses.popular_courses(:course_term, :course_year)) ORDER BY ID`;
  connection.execute(
    selectStatement,
    {course_term: request.params.course_term, course_year: request.params.course_year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}


function ratingCourses(request, response) {
  var selectStatement = `SELECT ders_kod FROM table(rating_courses(:term, :year)) ORDER BY ID DESC`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function ratingTeachers(request, response) {
  var selectStatement = `SELECT emp_id FROM table(rating_teachers(:term, :year)) ORDER BY ID DESC`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function allTeachersDers(request, response) {
  let ders_kod_t = request.params.dersKod.replace('+', ' ').toUpperCase();
  var selectStatement = `SELECT distinct(emp_id) FROM course_sections WHERE term = :term AND year = :year AND ders_kod = :dersKod`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year, dersKod: {type: oracledb.STRING, val: ders_kod_t}},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}


function scheduleStudents(request, response) {
  var selectStatement = `SELECT distinct * FROM table(schedule_student(:id, :term, :year)) ORDER BY weekday, start_time`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year, id: {type: oracledb.STRING, val: request.params.id}},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function scheduleTeachers(request, response) {
  var selectStatement = `SELECT distinct * FROM table(schedule_teacher(:id, :term, :year)) ORDER BY weekday, start_time`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year, id: request.params.id},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function studentsNR(request, response) {
  var selectStatement = `SELECT stud_id FROM table(students_not_registered(:term, :year))`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function allStudents(request, response) {
  var selectStatement = `SELECT distinct(stud_id) FROM course_selections WHERE term = :term AND year = :year`;
  connection.execute(
    selectStatement,
    {term: request.params.term, year: request.params.year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function allTeachers(request, response) {
  var selectStatement = `SELECT distinct(emp_id) FROM course_sections WHERE term = :term AND year = :year`;
  connection.execute(
    selectStatement,
    {term: request.params.course_term, year: request.params.course_year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function allCourses(request, response) {
  var selectStatement = `SELECT distinct(ders_kod) FROM course_sections WHERE term = :term AND year = :year`;
  connection.execute(
    selectStatement,
    {term: request.params.course_term, year: request.params.course_year},
    { outFormat: oracledb.OBJECT },
    function (err, result) {
      if (err) {
        response.writeHead(500, { "Content-Type": "application/json" });
        response.end(
          JSON.stringify({
            status: 500,
            message: "Error getting the poplar courses",
            detailed_message: err.message,
          })
        );
      } else {
        response.writeHead(200, { "Content-Type": "application/json" });
        response.end(JSON.stringify(result.rows));
      }
    }
  );
}

function popularTeachers(request, response) {
    let course_type = request.params.course_type;
    let ders_kod_t = request.params.ders_kod.replace('+', ' ').toUpperCase();
    var selectStatement = `SELECT emp_id FROM table(pkg_teachers_section.popular_teachers_${course_type}(:course_term, :course_year, :ders_kod)) ORDER BY ID`;
    connection.execute(
      selectStatement,
      {course_term: request.params.course_term, course_year: request.params.course_year, "ders_kod": {type: oracledb.DB_TYPE_VARCHAR, val : ders_kod_t}},
      { outFormat: oracledb.OBJECT },
      function (err, result) {
        if (err) {
          response.writeHead(500, { "Content-Type": "application/json" });
          response.end(
            JSON.stringify({
              status: 500,
              message: "Error getting the popular teachers " + course_type,
              detailed_message: err.message,
            })
          );
        } else {
          response.writeHead(200, { "Content-Type": "application/json" });
          response.end(JSON.stringify(result.rows));
        }
      }
    );
  }