package sm.ac.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sm.ac.app.dto.JobCategoryDto;
import sm.ac.app.dto.JobFieldDto;
import sm.ac.app.service.JobCategoryService;
import sm.ac.app.service.JobFieldService;

import java.util.List;

@RestController
@RequestMapping("/jobs")
public class JobController {
    private final JobFieldService jobFieldService;
    private final JobCategoryService jobCategoryService;

    public JobController(JobFieldService jobFieldService, JobCategoryService jobCategoryService) {
        this.jobFieldService = jobFieldService;
        this.jobCategoryService = jobCategoryService;
    }

    // 📌 직종 목록 조회 (job_fields)
    @GetMapping("/fields")
    public List<JobFieldDto> getJobFields() {
        return jobFieldService.getJobFields();
    }

//    // 📌 특정 직종의 직군 목록 조회 (job_categories)
//    @GetMapping("/categories/{fieldId}")
//    public List<JobCategoryDto> getJobCategories(@PathVariable int fieldId) {
//        return jobCategoryService.getJobCategoriesByField(fieldId);
//    }
}
