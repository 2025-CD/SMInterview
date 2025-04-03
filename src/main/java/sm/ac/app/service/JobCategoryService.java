package sm.ac.app.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sm.ac.app.dto.JobCategoryDto;

import sm.ac.app.frame.InterviewService;
import sm.ac.app.repository.JobCategoryRepository;


import java.util.List;

@Service
@RequiredArgsConstructor
public class JobCategoryService implements InterviewService<String, JobCategoryDto> {
    //인터페이스가 될 수 없다.
    //보통 controller가 호출하기 때문.
    //RequiredArgsConstructor를 써주면 CustService 객체가 생성될때 자동으로 custRepository 생성
    //RequiredArgsContructor를 사용하면, 필드를 final로..
    final JobCategoryRepository jobCategoryRepository;

    @Override
    public void add(JobCategoryDto jobCategoryDto) throws Exception {
        jobCategoryRepository.insert(jobCategoryDto);



    }

    @Override
    public void modify(JobCategoryDto jobCategoryDto) throws Exception {
        jobCategoryRepository.update(jobCategoryDto);


    }

    @Override
    public void del(String s) throws Exception {
        jobCategoryRepository.delete(s);

    }

    @Override
    public JobCategoryDto get(String s) throws Exception {
        return jobCategoryRepository.selectOne(s);
    }

    @Override
    public List<JobCategoryDto> get() throws Exception {
        return jobCategoryRepository.select();
    }

//    public List<CustDto> findByName(String name) throws Exception {
//        return usersRepository.findByName(name);
//    }
//
//    public Page<CustDto> getPage(int pageNo) throws Exception {
//        PageHelper.startPage(pageNo,5);
//        return usersRepository.getpage();
//    }
//
//    public boolean hasPurchasedPT(String custId) {
//        return usersRepository.hasPurchasedPT(custId) > 0;
//    }



}
